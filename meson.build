project(
    'primeindicator',
    'vala', 'c',
    version: '0.0.1'
)

i18n = import('i18n')
gettext_name = meson.project_name() + '-indicator'

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

wingpanel_dep = dependency('wingpanel-2.0')

indicator_dir_cmd = run_command('pkg-config', 'indicator3-0.4', '--variable=indicatordir')
if indicator_dir_cmd.returncode() != 0
  message ('Indicator directory not found')
endif

indicator_dir = indicator_dir_cmd.stdout().strip()

# Other configs
conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('AYANATAINDICATORDIR', indicator_dir)
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w'
]

shared_module(
    meson.project_name(),
    'src/PrimeIndicator.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        meson.get_compiler('vala').find_library('posix'),
        wingpanel_dep
    ],
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
)


subdir('data')
subdir('po')
