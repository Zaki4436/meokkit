#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.8"
FLUTTER_SHA256="baf7dcc5a3dbba60fe863bf493a6cf203195621f7786eaa5a1bba02cd0d87dd2"
FLUTTER_DIR="${HOME}/.cache/flutter-${FLUTTER_VERSION}"
FLUTTER_ARCHIVE="${TMPDIR:-/tmp}/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  mkdir -p "${HOME}/.cache"
  curl --fail --location --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    --output "${FLUTTER_ARCHIVE}"
  echo "${FLUTTER_SHA256}  ${FLUTTER_ARCHIVE}" | sha256sum --check
  mkdir -p "${FLUTTER_DIR}"
  tar -xJf "${FLUTTER_ARCHIVE}" -C "${FLUTTER_DIR}" --strip-components=1
  rm -f "${FLUTTER_ARCHIVE}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter config --no-analytics --enable-web
flutter pub get
flutter build web --release
