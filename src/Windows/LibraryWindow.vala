/*
 * Copyright (c) 2021 Andrew Vojak (https://avojak.com)
 *
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
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Windows.LibraryWindow : Hdy.Window {

    public weak Replay.Application app { get; construct; }

    private Replay.Services.LibraryWindowActionManager action_manager;
    private Gtk.AccelGroup accel_group;

    private Replay.Widgets.Dialogs.PreferencesDialog? preferences_dialog = null;

    private Replay.Views.LibraryView view;

    public LibraryWindow (Replay.Application application) {
        Object (
            title: Constants.APP_NAME,
            application: application,
            app: application,
            border_width: 0,
            resizable: true,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        accel_group = new Gtk.AccelGroup ();
        add_accel_group (accel_group);
        action_manager = new Replay.Services.LibraryWindowActionManager (app, this);

        view = new Replay.Views.LibraryView ();
        view.game_selected.connect (launch_game);

        add (view);

        restore_window_position ();

        this.destroy.connect (() => {
            // Do stuff before closing the library
            //  GLib.Process.exit (0);
        });

        this.delete_event.connect (before_destroy);

        show_app ();
    }

    private void restore_window_position () {
        move (Replay.Application.settings.get_int ("pos-x"), Replay.Application.settings.get_int ("pos-y"));
        resize (Replay.Application.settings.get_int ("window-width"), Replay.Application.settings.get_int ("window-height"));
    }

    private void show_app () {
        show_all ();
        present ();
    }

    public bool before_destroy () {
        update_position_settings ();
        destroy ();
        return true;
    }

    private void update_position_settings () {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        Replay.Application.settings.set_int ("pos-x", x);
        Replay.Application.settings.set_int ("pos-y", y);
        Replay.Application.settings.set_int ("window-width", width);
        Replay.Application.settings.set_int ("window-height", height);
    }

    public void reload_library () {
        debug ("Reloading library...");
        foreach (var game in Replay.Core.Client.get_default ().game_library.get_games ()) {
            var cores = Replay.Core.Client.get_default ().core_repository.get_cores_for_rom (GLib.File.new_for_path (game.rom_path));
            var core_names = new Gee.ArrayList<string> ();
            foreach (var core in cores) {
                core_names.add (core.info.core_name);
            }
            debug ("Adding game %s", game.display_name);
            view.add_game (game);
            //  layout.add_game (game, core_names);
        }
        //  var games_by_system = new Gee.HashMap<string, Gee.List<Replay.Models.Game>> ();
        //  foreach (var game in Replay.Core.Client.get_default ().game_library.get_games ()) {
        //      Replay.Models.LibretroCore? core = Replay.Core.Client.get_default ().core_repository.get_core_for_rom (GLib.File.new_for_path (game.rom_path));
        //      var key = core != null ? core.info.system_id : "";
        //      if (!games_by_system.has_key (key)) {
        //          games_by_system.set (key, new Gee.ArrayList<Replay.Models.Game> ());
        //      }
        //      games_by_system.get (key).add (game);
        //  }
        //  layout.set_games (games_by_system);
    }

    public void reload_systems () {
        debug ("Reloading systems...");
        foreach (var core in Replay.Core.Client.get_default ().core_repository.get_cores ()) {
            //  layout.add_view_for_core (core);
        }
    }

    public void show_favorites_view () {
        //  layout.show_favorites_view ();
    }

    public void show_preferences_dialog () {
        if (preferences_dialog == null) {
            preferences_dialog = new Replay.Widgets.Dialogs.PreferencesDialog (this);
            preferences_dialog.show_all ();
            preferences_dialog.destroy.connect (() => {
                preferences_dialog = null;
            });
        }
        preferences_dialog.present ();
    }

    public void toggle_sidebar () {
        view.toggle_sidebar ();
    }

    private void launch_game (Replay.Models.Game game) {
        Replay.Core.Client.get_default ().emulator_manager.launch_game (GLib.File.new_for_path (game.rom_path).get_uri ());
        Replay.Core.Client.get_default ().game_library.update_last_run_date (game);
    }

}