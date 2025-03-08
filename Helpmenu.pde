
class Help extends PosObject {
    ArrayList<String> lines;
    PVector textAreaSize;
    PVector size;
    float padding = 0;

    

    public Help(PVector center) {
       this.padding = 3*textSize;
       this.updateText();
       this.pos = new PVector(center.x - 0.5*this.size.x, center.y - 0.5*this.size.y);
    }
    
    void recalcSize() {
        float longestLine = 0;
        for (String line : this.lines) {
            float len = textWidth(line);
            if (longestLine < len) {
                longestLine = len;
            }
        }
        this.textAreaSize = new PVector(ceil(longestLine), lines.size()*(textSize));
        this.size = new PVector(this.textAreaSize.x + 2 * this.padding, this.textAreaSize.y + 2 * this.padding);
    }

    /**
     * Boolean to string (On/Off) 
     */
    String b2str(boolean value) {
        return value ? "On" : "Off";
    }

    /**
     * Insert new settings-values into help text
     */
    void updateText() {
        ArrayList<String> lines = new ArrayList<String>();
        lines.add("Help");
        lines.add("h: Help");
        lines.add("r: Clearn screen ");
        lines.add("");

        lines.add("Snake Size: " + SNEK_SEG_SIZE);
        lines.add("-: Make Smaller");
        lines.add("+: Make Bigger");
        lines.add("");

        lines.add("Animation Speed: " + frameRate + "fps");
        lines.add(",: Make faster");
        lines.add(".: Make slower");
        lines.add("");

        lines.add("Toggle:");
        lines.add("d: Move diagonally " + b2str(DIAG_MODE));
        lines.add("n: Snakes leave trails" + b2str(CLEAR_BG_MODE));
        lines.add("s: Varying segments " + b2str(VAR_SEG_SIZE));
        
        lines.add("p: Click to spawn one Snake" + b2str(SPAWN_MODE));        
        lines.add("  a: Spawn " +SPAWN_COUNT+ " new Snakes");
        lines.add("  +: Incerease number of new Snakes ");
        lines.add("  -: Decrease number of new Snakes");

        lines.add("o: Click to pause: " + b2str(STOP_MODE));
        
        lines.add("c: Align to Segments to Edge" + b2str(CENTER_MODE));
        lines.add("g: Align Snakes to grid (TODO) " + b2str(GRID_MODE)); // TODO what?
        lines.add("Size between Snakes-paths: " + GAP_SIZE);
        lines.add("b: Click to spawn bomb" + b2str(BOMB_MODE)); // TODO
        this.lines = lines;
        
        
        this.recalcSize();   
    }


    void draw() {
        noFill();
        stroke(200);
        rectMode(CORNER);
        rect(this.pos.x, this.pos.y, this.size.x, this.size.y);
        fill(200);
        for (int l = 0; l < lines.size(); l++) {
            text(lines.get(l),this.pos.x+this.padding, this.pos.y+this.padding + (1+l)*(textSize));
        }
    }
    
}
