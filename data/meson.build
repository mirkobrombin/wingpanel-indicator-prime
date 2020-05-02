icons = [
    'prime-indicator-hybrid-symbolic',
    'prime-indicator-intel-symbolic',
    'prime-indicator-nvidia-symbolic'
]

foreach i : icons
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps')
    )
endforeach
