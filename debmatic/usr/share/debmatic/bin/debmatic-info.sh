#!/bin/bash
echo "debmatic version: `dpkg -s debmatic | grep '^Version: ' | cut -d' ' -f2`"

if [ $EUID != 0 ]; then
  echo "Please run as root"
  exit 1
fi

if [ -e /etc/default/debmatic ]; then
  . /etc/default/debmatic
fi

lsmod | grep -q eq3_char_loop || modprobe -q -n eq3_char_loop && RC=$? || RC=$?
if [ $RC -eq 0 ]; then
  MODULE_STATE="Available"
else
  MODULE_STATE="Not available"
fi
echo "Kernel modules: $MODULE_STATE"

if [ `systemctl is-active debmatic.service` == "active" ]; then
  if [ -e /var/status/startupFinished ]; then
    . /var/hm_mode
  fi
else
  . /usr/share/debmatic/bin/detect_hardware.inc
fi

if [ "$(echo /sys/class/raw-uart/raw-uart*)" != "/sys/class/raw-uart/raw-uart*" ]; then
  RAW_UART_STATE="Available"
else
  RAW_UART_STATE="Not available"
fi
echo "Raw UART dev:   $RAW_UART_STATE"

if [ -f /proc/device-tree/model ] && [ `grep -c "Raspberry Pi 3" /proc/device-tree/model` == 1 ]; then
  if cmp -s /proc/device-tree/aliases/uart0 /proc/device-tree/aliases/serial0; then
    UART_STATE="Assigned to GPIO pins"
  else
    UART_STATE="Not assigned to GPIO pins"
  fi
  echo "Rasp.Pi3 UART:  $UART_STATE"
fi

if [ -z "$HM_HMRF_DEV" ]; then
  echo "HMRF Hardware:  unknown"
else
  echo "HMRF Hardware:  $HM_HMRF_DEV"

  if [ ! -z "$HM_HMRF_DEVTYPE" ]; then
    echo " Connected via: $HM_HMRF_DEVTYPE ($HM_HMRF_DEVNODE)"
  fi

  if [ -z "$HM_HMRF_SERIAL" ]; then
    HM_HMRF_SERIAL='unknown'
  fi
  echo " Board serial:  $HM_HMRF_SERIAL"

  if [ -z "$HM_HMRF_ADDRESS" ]; then
    HM_HMRF_ADDRESS='unknown'
  fi
  echo " Radio MAC:     $HM_HMRF_ADDRESS"
fi

if [ -z "$HM_HMIP_DEV" ]; then
  echo "HMIP Hardware:  unknown"
else
  echo "HMIP Hardware:  $HM_HMIP_DEV"

  if [ ! -z "$HM_HMIP_DEVTYPE" ]; then
    echo " Connected via: $HM_HMIP_DEVTYPE ($HM_HMIP_DEVNODE)"
  fi

  if [ -z "$HM_HMIP_SGTIN" ]; then
    HM_HMIP_SGTIN='unknown'
  fi
  echo " SGTIN:         $HM_HMIP_SGTIN"

  if [ -z "$HM_HMIP_ADDRESS" ]; then
    HM_HMIP_ADDRESS='unknown'
  fi
  echo " Radio MAC:     $HM_HMIP_ADDRESS"
fi
