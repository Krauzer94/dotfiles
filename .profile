# Correcly theme GNOME
apply_gnome_themes() {
    # Themes, icons, cursor and fonts
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
    gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
    gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
    gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
    gsettings set org.gnome.desktop.interface font-name "Cantarell 11"
}

# Detect the DE
if [[ "$XDG_CURRENT_DESKTOP" =~ "GNOME" ]]; then
    apply_gnome_themes
fi
