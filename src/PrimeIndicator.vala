/*
 * Copyright (c) 2019 Mirko Brombin (https://linuxhub.it)
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */
public class Prime.Indicator : Wingpanel.Indicator 
{
    private Wingpanel.Widgets.OverlayIcon display_widget;
    private Gtk.Dialog confirm_dialog;
    private Gtk.Grid main_widget;

    public Indicator () 
    {
        Object (
            code_name : "prime-indicator",
            display_name : _("Prime Indicator"),
            description: _("A PRIME mode switcher for wingpanel.")
        );
    }

    construct 
    {
        string icon = "";

        if (current_mode (true) == "nvidia")
            icon = "prime-indicator-nvidia-symbolic";
        else if (current_mode (true) == "intel")
            icon = "prime-indicator-intel-symbolic";
        else
            icon = "prime-indicator-hybrid-symbolic";

        display_widget = new Wingpanel.Widgets.OverlayIcon (icon);

        // create menu items
        var current_gpu_label = new Gtk.Label (current_mode ());

        var powersaving_switch_button = new Gtk.ModelButton ();
        powersaving_switch_button.text = _("Switch to Intel (Power saving)");

        var performance_switch_button = new Gtk.ModelButton ();
        performance_switch_button.text = _("Switch to NVIDIA (Performance mode)");

        var ondemand_switch_button = new Gtk.ModelButton ();
        ondemand_switch_button.text = _("Switch to NVIDIA (On-Demand)");

        var settings_button = new Gtk.ModelButton ();
        settings_button.text = _("NVIDIA Settings");

        // add items to menu
        main_widget = new Gtk.Grid ();
        main_widget.attach (current_gpu_label, 0, 0);
        main_widget.attach (new Wingpanel.Widgets.Separator (), 0, 1);
        main_widget.attach (powersaving_switch_button, 0, 2);
        main_widget.attach (performance_switch_button, 0, 3);

        // append ondemand item only if supported
        if (check_ondemand ())
            main_widget.attach (ondemand_switch_button, 0, 4);

        main_widget.attach (new Wingpanel.Widgets.Separator (), 0, 5);
        main_widget.attach (settings_button, 0, 6);

        // ndicator should be visible at startup
        this.visible = true;

        powersaving_switch_button.clicked.connect (() => 
        {
            int response = confirm_mode_switch ("Intel (Power saving)");
            current_gpu_label.set_text ("Intel GPU");
            if (response == Gtk.ResponseType.OK) 
            {
                current_gpu_label.set_text ("Intel GPU");
                Posix.system ("pkexec prime-select intel");
            }
        });

        performance_switch_button.clicked.connect (() => 
        {
            int response = confirm_mode_switch ("NVIDIA (Performance mode)");
            if (response == Gtk.ResponseType.OK) 
            {
                current_gpu_label.set_text ("NVIDIA GPU");
                Posix.system ("pkexec prime-select nvidia");
            }
        });

        ondemand_switch_button.clicked.connect (() => 
        {
            int response = confirm_mode_switch ("NVIDIA (On-Demand)");
            if (response == Gtk.ResponseType.OK) 
            {
                current_gpu_label.set_text ("NVIDIA GPU");
                Posix.system ("pkexec prime-select on-demand");
            }
        });

        settings_button.clicked.connect (() => 
        {
            Posix.system ("nvidia-settings &");
        });
    }

    // show a dialog to confirm mode switch
    private int confirm_mode_switch (string mode) 
    {
        string message = _("Do you want to switch GPU now?") + " " 
            + _("You need to log out and then log back in to switch the GPU to") + " " + mode;

        confirm_dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.NONE, message);
        confirm_dialog.set_deletable(false);
        confirm_dialog.connect("delete_event", Gtk.ResponseType.CANCEL);
        confirm_dialog.add_button(Gtk.STOCK_APPLY, Gtk.ResponseType.OK);
        confirm_dialog.add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL);
        
        int response = confirm_dialog.run();
        confirm_dialog.destroy();
        
        return response;
    }

    // check if on-demand is supported
    private bool check_ondemand ()
    {
        string response;
        
        Process.spawn_command_line_sync ("prime-select", out response);

        if (response.contains ("on-demand"))
            return true;

        return false;
    }

    // get selected mode
    private string current_mode (bool raw=false) 
    {
        string response;
        
        Process.spawn_command_line_sync ("prime-select query", out response);
        response = response.split("\n")[0];

        if (raw)
            return response.split("\n")[0];

        switch (response) 
        {
            case "intel":
                response = _("Intel (Power Saving)");
            break;
            case "nvidia":
                response = _("NVIDIA (Performance Mode)");
            break;
            case "on-demand":
                response = _("NVIDIA (On-Demand)");
            break;
        }
        
        return response;
    }

    // method called to get the widget that is displayed in the panel
    public override Gtk.Widget get_display_widget () 
    {
        return display_widget;
    }

    // method called to get the widget that is displayed in the popover
    public override Gtk.Widget? get_widget () 
    {
        return main_widget;
    }

    // method called when the indicator popover opened
    public override void opened () 
    {
        // method to get some extra information while displaying the indicator
    }

    // method called when the indicator popover closed
    public override void closed () 
    {
        // stuff not shown anymore, now you can free some RAM, stop timers or anything else...
    }
}

public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) 
{
    debug ("Activating Prime Indicator");

    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        // display prime indicator only in the "normal" session, not on the login screen, so stop here!
        return null;
    }

    // indicator creation
    var indicator = new Prime.Indicator ();

    // return the newly created indicator
    return indicator;
}   
