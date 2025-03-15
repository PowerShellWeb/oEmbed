if ($this.thumbnail_url) {
    return "[![$($this.title)]($($this.thumbnail_url))]($($this.url))"
}
elseif ($this.title) {
    "[$($this.title)]($($this.url))"
}