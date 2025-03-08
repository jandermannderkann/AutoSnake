
class Help {
    ArrayList<String> lines;

    public Help() {
    }


    void draw() {

        ArrayList<String> lines = new ArrayList<String>();
        lines.add("Help");
        lines.add("h: Help");
        lines.add("r: Clearn Screen ");
        lines.add("d: Move diagonally " + DIAG_MODE);
        lines.add("n: Draw Trails" + CLEAR_BG_MODE);
        lines.add("s: Uniform segment size " + VAR_SEG_SIZE);
        
        lines.add("-: Smaller" + SNEK_SEG_SIZE);
        lines.add("+: Bigger");
        
        lines.add("p: Click to spawn one snake (Spawn mode)" + SPAWN_MODE);
        lines.add("Spawn Mode: ");
        lines.add("  a: Spawn multiple: " + SPAWN_COUNT);
        lines.add("  +: Spawn more ");
        lines.add("  -: Spawn less");

        lines.add(",: Animation faster");
        lines.add(".: Animation slower");
        lines.add("o: Click to stop" + STOP_MODE);
        
        lines.add("c: Centered segments " + CENTER_MODE);
        lines.add("g: Align to grid (TODO) " + GRID_MODE); // TODO what?
        lines.add(" : GAP_SIZE " + GAP_SIZE);
        lines.add("b: BOMB_MODE TODO" + BOMB_MODE); // TODO
        this.lines = lines;

        int lineHeight = 15;
        for (int l = 0; l < lines.size(); l++) {
            stroke(200);
            fill(200);
            textSize(15);
            text(lines.get(l),100, 100+ l*15);
        }
    }
    
}