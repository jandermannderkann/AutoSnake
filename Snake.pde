
class SnekSeg extends PosObject {
    // PVector pos;
    float size;
    color col; 

    public SnekSeg(PVector pos, float size, color col) {
        this.pos = pos;
        float shrink = 0;
        if (VAR_SEG_SIZE) {
            shrink = random(0,SNEK_SEG_SIZE/2);
        }
        this.size = size - shrink;

        this.col = col;
        if (COLOR_MODE==0) {
            //slight hue
            this.col = color(red(this.col)+random(0,50), green(this.col)+random(0,50),blue(this.col)+random(0,50));
        } else if (COLOR_MODE == 1) {
            //rainbow
            this.col = randCol();
        } else if (COLOR_MODE ==2) {
            // strong hue
            this.col = color(red(this.col)+random(0,100), green(this.col)+random(0,100),blue(this.col)+random(0,100));
        } else if (COLOR_MODE ==3) {
            // greyscale
            this.col = color(random(100,200));
        }
    }
}

class Snek extends PosObject {
    // PVector pos;
    PVector speed = new PVector(0,SNEK_SEG_SIZE);
    
    World w;

    int age;
    color col;
    int bored_after;
    int bored_timer;
    int size;
    
    int newSegs = 0;

    ArrayList<SnekSeg> segs = new ArrayList<SnekSeg>();
    SnekSeg lastSeg;

    // ArrayList<PVector> segs = new ArrayList<PVector>();
    // ArrayList<float> segSize = new ArrayList<float>();

    public Snek(World w, float x, float y) {
        this.age = 0;
        this.w = w;
        
        if (x == 0 && y==0) {
            //random start position
            x = random(0,width);
            y = random(0,height);

        }
        
        if (GRID_MODE) {
            x = int(x/SNEK_SEG_SIZE)*SNEK_SEG_SIZE;
            y = int(y/SNEK_SEG_SIZE)*SNEK_SEG_SIZE;
        }
        this.pos = new PVector(x,y);
        
        //random size
        this.size = 1;
        this.segs.add(new SnekSeg(this.pos.copy(), SNEK_SEG_SIZE, this.col));

        //random timer
        if (VARYING_BOREDNESS) {
            this.bored_after = int(random(0,BORED_AFTER));
        } else {
            this.bored_after = BORED_AFTER;
        }
        this.bored_timer = 0;
        //random color
        this.col = color(random(200),random(50,100), random(0,200));

        // random speed
        PVector speed = new PVector(0, SNEK_SEG_SIZE);
        speed.rotate(radians(random(0,360)));
        this.speed = speed;
        random_direction();
    }

    void addSeg() {
        // print("++ ");
        this.newSegs++;
        this.size++;
    }

    /**
     * For a given turn-radius, returns possible total turn degrees. 
     * This is all multiples of the turn-radius, which are not 180, or 180+-turn_radius. 
     * Ex: for 60: 0,60,-60,120,-120
     */
    ArrayList<Float> get_turn_options(int turn_radius) {
        ArrayList<Float> options = new ArrayList<Float>();
        float maxRadius = 180-turn_radius;
        if (!VARIABLE_TURNS) {
            maxRadius = turn_radius;
        }

        for (int degrees = 0; degrees <= maxRadius; degrees += turn_radius) {
            options.add(new Float(degrees));
            options.add(new Float(degrees*-1));
        }   
        return options;
    }

    float align_heading_to_turn_options(float heading, ArrayList<Float> options) {
        float smallest_diff = 360;
        float best_option = 0;
        for (float option: options) {
            if (heading - option <smallest_diff ) {
                smallest_diff = heading-option;
                best_option = option;
            }
        }
        return best_option;
    }

    void random_direction() {
        int turnRadius = TURN_RADIUS;
        float heading = degrees(this.speed.heading());
        
        ArrayList<Float> options  = get_turn_options(turnRadius);
        
        //reset to multiples of turn-radius
        float aligned_Heading = int(heading / turnRadius)*turnRadius;
        float rotation = aligned_Heading-heading; // turn back to aligned
        
        if (DIAG_MODE) {
            rotation += random(0,5);
        }

        int select = int(random(0,options.size()));
        rotation += options.get(select);

        this.speed.rotate(radians(rotation));
    }
    
    boolean avoidCollision() {
        boolean collision = this.w.checkCollision(this);
        int trys = 4;
        while(collision & trys>0) {
            random_direction();
            collision = this.w.checkCollision(this);
            trys--;
        }
        // all blocked
        if (trys <1) {
            return false;
        }
        return true;
    }

    void move() {
        if (DRUNK_MODE) {
            for (SnekSeg s : this.segs) {
                s.pos.add(PVector.mult(this.speed,0.1));
            }
        }
        this.pos.add(this.speed);
        PVector head = this.pos.copy();
        this.segs.add( new SnekSeg(head, SNEK_SEG_SIZE, this.col));

        if (this.newSegs > 0) {
            this.newSegs -= 1;
        } else {
            this.lastSeg = segs.get(0);
            this.segs.remove(0);
        }


    }
    boolean dead() {
        return this.age > MAX_AGE;
    }

    PVector getNextPos() {
        return PVector.add(this.pos, this.speed);
    }

    void act() {
        boolean stuck = !this.avoidCollision();
        if (!stuck) {
            this.move();
        } else {
            //is stuck
            if (this.segs.size() > 1 ) {
              this.segs.remove(0);
            } else {
              println("Snek has length 0");
            }
            
        }

        if (random(0,100)>CHANCE_GROW) {
            this.addSeg();
        }
        if (this.bored_timer > this.bored_after && random(0,100)>CHANCE_TURN) {
            this.random_direction();
            this.bored_timer = 0;
        }
        this.bored_timer ++;
        this.age ++;

    }
    void drawSeg(SnekSeg seg) {
        drawSeg(seg, seg.col);
    }

    void drawSeg(SnekSeg seg, color c) {
        PVector p = seg.pos;
        float size = seg.size;

        fill(c);
        if (RECT_MODE) {
            rect(p.x, p.y, size, size);
        } else {
            circle(p.x, p.y, size);
        }
    }

    void draw() {

        if (CENTER_MODE) rectMode(CENTER);
        else rectMode(CORNER);
        
        noStroke();
        for (SnekSeg seg: this.segs) {
           drawSeg(seg);
        }
        // dark mode
        if (!CLEAR_BG_MODE) {
            drawSeg(lastSeg, segs.get(0).col);
            drawSeg(lastSeg, LAST_SEG_COL);
        }
    }

    boolean collides(PVector head, float headSize) {
        for (SnekSeg seg: this.segs) {
            if (seg.pos.dist(head) < SNEK_SEG_SIZE/2 + headSize/2 + GAP_SIZE) {
                // print(String.format("S %f,%f COLLIDES w %f,%f",seg.x, seg.y, head.x, head.y));
                return true;
            }
        }
        return false;
    }
}
