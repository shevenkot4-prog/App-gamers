String humanizeError(Object error, {String fallback = 'Ocurrió un error inesperado.'}) {
  final raw = error.toString();
  if (raw.contains('SocketException')) return 'Sin conexión. Verifica tu red e intenta de nuevo.';
  if (raw.contains('401') || raw.contains('JWT')) return 'Tu sesión expiró. Inicia sesión nuevamente.';
  if (raw.contains('permission') || raw.contains('row-level security')) {
    return 'No tienes permisos para esta acción.';
  }
  if (raw.contains('duplicate key')) return 'Este registro ya existe.';
  if (raw.contains('PGRST')) return 'Error de datos en Supabase. Revisa configuración y tablas.';
  return '$fallback\nDetalle: $raw';
}
