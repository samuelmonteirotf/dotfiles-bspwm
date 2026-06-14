#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════╗
# ║  rofi-screenshot · NEXUS · Red Team                       ║
# ╚══════════════════════════════════════════════════════════╝

# Opções do menu
screen="󰹑  Tela Inteira"
area="󰆞  Selecionar Área"
window="󰖯  Janela Ativa"
delay="󱎫  Delay (5 segundos)"

options="$screen\n$area\n$window\n$delay"

# Abre o rofi para escolher
chosen="$(echo -e "$options" | rofi -dmenu -p " Screenshot" -theme-str 'window {width: 400px;} listview {lines: 4;}')"

# Pasta de destino
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="screenshot_$(date +%Y%m%d_%H%M%S).png"
path="$dir/$file"

case "$chosen" in
    "$screen")
        sleep 0.2
        maim "$path"
        xclip -selection clipboard -t image/png -i "$path"
        dunstify -u low -i "$path" "Screenshot" "Tela inteira salva em:\n$file"
        ;;
    "$area")
        maim -su "$path"
        xclip -selection clipboard -t image/png -i "$path"
        dunstify -u low -i "$path" "Screenshot" "Área selecionada salva em:\n$file"
        ;;
    "$window")
        sleep 0.2
        # Captura a janela ativa pegando a ID via xdotool ou xprop (como fallback)
        if command -v xdotool >/dev/null; then
            win_id=$(xdotool getactivewindow)
        else
            win_id=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)" | awk '{print $5}')
        fi
        maim -i "$win_id" "$path"
        xclip -selection clipboard -t image/png -i "$path"
        dunstify -u low -i "$path" "Screenshot" "Janela ativa salva em:\n$file"
        ;;
    "$delay")
        dunstify -t 5000 "Screenshot" "Capturando em 5 segundos..."
        sleep 5
        maim "$path"
        xclip -selection clipboard -t image/png -i "$path"
        dunstify -u low -i "$path" "Screenshot" "Tela cheia com delay salva em:\n$file"
        ;;
esac
