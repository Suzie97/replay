/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022 Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Replay.Views.LibraryView : Gtk.Grid {

    private const int RECENTLY_PLAYED_THRESHOLD_DAYS = 30;

    private const string ALL_VIEW_NAME = "collection:all";
    private const string FAVORITES_VIEW_NAME = "collection:favorites";
    private const string RECENT_VIEW_NAME = "collection:recent";
    private const string UNPLAYED_VIEW_NAME = "collection:unplayed";

    private Replay.Layouts.LibraryLayout library_layout;

    public LibraryView () {
        Object (
            expand: true
        );
    }

    construct {
        library_layout = new Replay.Layouts.LibraryLayout ();
        library_layout.add_collection (
            _("All Games"),
            "folder-saved-search",
            ALL_VIEW_NAME, 
            new Replay.Models.Functions.AllGamesFilterFunction (),
            new Replay.Models.Functions.AlphabeticalSortFunction ()
        );
        library_layout.add_collection (
            _("Favorites"),
            "starred",
            FAVORITES_VIEW_NAME,
            new Replay.Models.Functions.FavoritesFilterFunction (),
            new Replay.Models.Functions.AlphabeticalSortFunction ()
        );
        library_layout.add_collection (
            _("Recently Played"),
            "document-open-recent",
            RECENT_VIEW_NAME,
            new Replay.Models.Functions.RecentsFilterFunction (),
            new Replay.Models.Functions.LastPlayedSortFunction ()
        );
        library_layout.add_collection (
            _("Unplayed"),
            "mail-unread",
            UNPLAYED_VIEW_NAME,
            new Replay.Models.Functions.UnplayedFilterFunction (),
            new Replay.Models.Functions.AlphabeticalSortFunction ()
        );

        //  foreach (var platform in Replay.Core.Client.get_default ().game_repository.get_platforms ()) {
        //      library_layout.add_system (
        //          platform, 
        //          "input-gaming", 
        //          "platform:%s".printf (platform), 
        //          new Replay.Models.Functions.PlatformFilterFunction (platform), 
        //          new Replay.Models.LibraryItemSortFunction ((library_item_1, library_item_2) => {
        //              return library_item_1.game.display_name.ascii_casecmp (library_item_2.game.display_name);
        //          })
        //      );
        //  }

        library_layout.game_selected.connect ((game) => {
            game_selected (game);
        });

        attach (library_layout, 0, 0);

        show_all ();

        // TODO: Load last-shown view, or show welcome view
        library_layout.select_view (ALL_VIEW_NAME);
    }

    public void add_game (Replay.Models.Game game) {
        library_layout.add_game (game);
    }

    public void toggle_sidebar () {
        library_layout.toggle_sidebar ();
    }

    public void set_searchbar_visible (bool visible) {
        library_layout.set_searchbar_visible (visible);
    }

    public signal void game_selected (Replay.Models.Game game);

}
