/*
 * Copyright (c) 2022 Andrew Vojak (https://avojak.com)
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

public class Replay.Services.GameLibrary : GLib.Object {

    private static GLib.Once<Replay.Services.GameLibrary> instance;
    public static unowned Replay.Services.GameLibrary get_default () {
        return instance.once (() => { return new Replay.Services.GameLibrary (); });
    }

    public Replay.Services.SQLClient sql_client { get; set; }

    // ROM path to game model mapping
    private Gee.Map<string, Replay.Models.Game> known_games = new Gee.HashMap<string, Replay.Models.Game> ();

    private GameLibrary () {
    }

    public void set_games (Gee.List<Replay.Models.Game> games) {
        known_games.clear ();
        foreach (var game in games) {
            if (!known_games.has_key (game.rom_path)) {
                known_games.set (game.rom_path, game);
            }
        }
    }

    public Gee.Collection<Replay.Models.Game> get_games () {
        return known_games.values;
    }

    public void set_game_played (Replay.Models.Game game, bool played) {
        foreach (var entry in known_games.entries) {
            if (entry.value == game) {
                entry.value.is_played = played;
                if (!played) {
                    entry.value.last_played = null;
                }
                // TODO: Persist this change
                return;
            }
        }
    }

    public void set_game_favorite (Replay.Models.Game game, bool favorite) {
        foreach (var entry in known_games.entries) {
            if (entry.value == game) {
                entry.value.is_favorite = favorite;
                // TODO: Persist this change
                return;
            }
        }
    }

    public void update_last_run_date (Replay.Models.Game game) {
        foreach (var entry in known_games.entries) {
            if (entry.value == game) {
                entry.value.last_played = new GLib.DateTime.now_utc ();
                // TODO: Persist this change
                return;
            }
        }
    }

    //  public void initialize () {
        // Load known ROMs from database
        // TODO
        // Check whether known ROMs can still be found on the filesystem
        // TODO
        // Check for bundled ROMs not already present in the database
        //  scan_rom_directory (GLib.File.new_for_path (Constants.ROM_DIR));
    //  }

    //  private void scan_rom_directory (GLib.File rom_directory) {
    //      if (!rom_directory.query_exists ()) {
    //          warning ("Bundled ROM directory not found: %s", rom_directory.get_path ());
    //          return;
    //      }
    //      GLib.FileEnumerator file_enumerator;
    //      try {
    //          file_enumerator = rom_directory.enumerate_children ("standard::*", GLib.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
    //      } catch (GLib.Error e) {
    //          warning ("Error while enumerating files in bundled ROM directory: %s", e.message);
    //          return;
    //      }
    //      GLib.FileInfo info;
    //      try {
    //          while ((info = file_enumerator.next_file ()) != null) {
    //              if (info.get_file_type () == GLib.FileType.DIRECTORY) {
    //                  continue;
    //              }
    //              // Can't make any assumptions about which file types are actually ROMs, but this is in the
    //              // bundled directory, so there *shouldn't* be anything else in there.
    //              on_rom_found (GLib.File.new_for_path (Constants.ROM_DIR + "/" + info.get_name ()));
    //          }
    //      } catch (GLib.Error e) {
    //          warning ("Error while iterating over files in bundled core directory: %s", e.message);
    //          return;
    //      }
    //  }

    //  private void on_rom_found (GLib.File rom_file) {
        // TODO: Create Game model
        //  rom_found ();

        //  if (!known_cores.has_key (core_info.core_name)) {
        //      debug ("Found bundled core %s for %s", core_info.core_name, core_info.system_name);
        //      // Store the core
        //      known_cores.set (core_info.core_name, new Replay.Models.LibretroCore () {
        //          path = core_file.get_path (),
        //          info = core_info
        //      });
        //      // Update the ROM extension map
        //      foreach (var extension in core_info.supported_extensions) {
        //          if (!rom_extensions.has_key (extension)) {
        //              rom_extensions.set (extension, new Gee.ArrayList<string> ());
        //          }
        //          rom_extensions.get (extension).add (core_info.core_name);
        //      }
        //  } else {
        //      warning ("Duplicate core files found for core name: %s, using first file found", core_info.core_name);
        //  }

        // TODO: Check if already in database
        //  bool is_new = false;
        //  debug ("Found bundled core: %s %s", core_info.core_name, is_new ? "(new)" : "");
        //  sql_client.insert_core (new Replay.Models.LibretroCore () {
        //      uri = core_file.get_uri (),
        //      info = core_info
        //  });
    //  }

    //  public signal void rom_found ();

}