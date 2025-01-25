int noSnek = 60;
int SNEK_SEG_SIZE = 15;
int BORED_AFTER = 10;
int CHANCE_TURN = 25;
int CHANCE_GROW = 95;
int MAX_AGE = 100000;
int MAX_SIZE = 100;


int GAP_SIZE = 3;

int fr = 30;
color bg = color(10);
color LAST_SEG_COL = color(10);


int BOMB_SIZE = 200;

boolean GRID_MODE = true;
boolean SPAWN_MODE = true;
boolean BOMB_MODE = true;

boolean DIAG_MODE = false;
boolean TURN_RESET_MODE = false;
boolean SHOW_BOMB = true;
boolean CLEAR_BG_MODE = true;

boolean VAR_SEG_SIZE = true;
int COLOR_MODE = 0;
boolean CENTER_MODE = true;




interface HasPos {
    PVector getPos();
    float x();
    float y();
    void sx(float x);
    void sy(float y);
}

class PosObject implements HasPos {
    PVector pos;

    PVector getPos() {
        return this.pos;
    }
    float x() {
        return this.pos.x;
    }
    float y() {
        return this.pos.y;
    }
    void sx(float x) {
        this.pos.x = x;
    }
    void sy(float y) {
        this.pos.y = y;
    }
}

color randCol() {
    return color(random(0,200), random(0,200), random(0,200));
}

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
            this.col = color(red(this.col)+random(0,50), green(this.col)+random(0,50),blue(this.col)+random(0,50));
        } else if (COLOR_MODE == 2) {
            this.col = randCol();
        }
    }
}

class Snek extends PosObject {
    // PVector pos;
    PVector speed = new PVector(0,SNEK_SEG_SIZE);

    World w;

    int age;
    color col;
    int bored_timer = int(random(0,BORED_AFTER));
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
        this.bored_timer = int(random(0,BORED_AFTER));
        //random color
        this.col = color(random(200),random(50,100), random(0,200));

        // random speed
        PVector speed = new PVector(0, SNEK_SEG_SIZE);
        this.speed = speed;
        random_direction();
    }

    void addSeg() {
        // print("++ ");
        this.newSegs++;
        this.size++;
    }

    void random_direction() {
        float turnDeg = 90;
        float currDeg = this.speed.heading();

        if(false) {
            int div = int(currDeg / 90);
            float newDeg = div*90;
            PVector newSpeed = PVector.fromAngle(radians(newDeg));
            newSpeed.setMag(this.speed.mag());
            this.speed=newSpeed;
        }

        if (DIAG_MODE) {
            turnDeg += random(0,5);
        }
        if (random(0,2)>1) {
            turnDeg *= -1;
        }
        

        this.speed.rotate(radians(turnDeg));
    }
    
    void avoidCollision() {
        boolean collision = this.w.checkCollision(this);
        int trys = 4;
        while(collision & trys>0) {
            random_direction();
            collision = this.w.checkCollision(this);
            trys--;
        }
        //if try <1;
    }

    void move() {
        this.pos.add(this.speed);
        PVector head = this.pos.copy();
        this.segs.add( new SnekSeg(head, SNEK_SEG_SIZE, this.col));
        // println(String.format("Moved to %f,%f by speed %f,%f",head.x, head.y, this.speed.x, this.speed.y));

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
        this.avoidCollision();

        this.move();

        if (random(0,100)>CHANCE_GROW) {
            this.addSeg();
        }
        if (this.bored_timer > BORED_AFTER && random(0,100)>CHANCE_TURN) {
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
        rect(p.x, p.y, size, size);
    }

    void draw() {

        if (CENTER_MODE) rectMode(CENTER);
        else rectMode(CORNER);
        
        noStroke();
        //for (SnekSeg seg: this.segs) {
        //    drawSeg(seg);
        //}
        drawSeg(lastSeg, segs.get(0).col);
        drawSeg(lastSeg, LAST_SEG_COL);

    }

    boolean collides(PVector head, float headSize) {
        for (SnekSeg seg: this.segs) {
            if (seg.pos.dist(head) <= SNEK_SEG_SIZE/2 + headSize/2 + GAP_SIZE) {
                // print(String.format("S %f,%f COLLIDES w %f,%f",seg.x, seg.y, head.x, head.y));
                return true;
            }
        }
        return false;
    }
}

class Help {
    ArrayList<String> lines;

    public Help() {
    }


    void draw() {

        ArrayList<String> lines = new ArrayList<String>();
        lines.add("Help");
        lines.add("d: Diag_MODE " + DIAG_MODE);
        lines.add("b: BOMB_MODE " + BOMB_MODE);
        lines.add("s: VAR_SEG_SIZE " + VAR_SEG_SIZE);
        lines.add("c: CENTER_MODE " + CENTER_MODE);
        lines.add("g: GRID_MODE" + GRID_MODE);
        lines.add("l: COLOR_MODE " + COLOR_MODE);
        lines.add(" : GAP_SIZE " + GAP_SIZE);
        lines.add("r: !reset ");
        lines.add("p: SPAWN_MODE" + SPAWN_MODE);
        lines.add("n: CLEAR_BG_MODE" + CLEAR_BG_MODE);
        this.lines = lines;

        int lineHeight = 15;
        for (int l = 0; l < lines.size(); l++) {
            stroke(200);
            fill(200);
            textSize(15);
            text(lines.get(l),100, 100+ l*15);
            println(lines.get(l));
        }
    }
    
}

class Bomb extends PosObject  {
    int age = 0;

    void act() {
        age++;
    }
    void dead () {

    }
    void draw () {
        // circle()
    }
}

class World {
    Help help;
    ArrayList<Snek> sneks = new ArrayList<Snek>();

    void reset() {
        this.sneks.clear();
    }


    void spawn(int noSnek) {
        for (int i = noSnek; i>0; i--) {
            this.sneks.add(new Snek(this,0,0));
        }
    }

    void bomb(float x, float y, float size) {
        PVector center = new PVector(x,y);
        
        for (Snek s: this.sneks) {
            float dist = s.pos.dist(center);
            if (dist<size) {
                PVector away = PVector.sub(s.pos,center);
                away.setMag(s.speed.mag());
                s.speed=away;
            }
        }

    }
    public World() {
        this.spawn(noSnek);
    }

    boolean checkCollision(Snek snekToCheck) {
        PVector newHead = snekToCheck.getNextPos();
        float size = SNEK_SEG_SIZE;

        for (Snek s: this.sneks) {
            if (s==snekToCheck) {continue;}
            if (s.collides(newHead, size)){
                return true;
            }
        }
        return false;
    }

    void constrain_to_world(Snek s) {
        if (s.x() > width-0) {
            s.sx(0);
        } else if (s.x() < 0) {
            s.sx(width);
        }
        if (s.y() > height-0) {
            s.sy(0);
        } else if (s.y() < 0) {
            s.sy(height);
        }
    }
    void act() {
        for (Snek s : this.sneks) {
            s.act();
        }
        for (Snek s : this.sneks) {
            constrain_to_world(s);
        }
    }

    void draw() {
        if (CLEAR_BG_MODE) {
            background(bg);
        } else {
            //fill(0,0,0,100);
            //rect(width/2,height/2,width, height);
        }
        for (Snek s : this.sneks) {
            s.draw();
        }
        if (this.help != null) {
            this.help.draw();
        }
    }
}

World w;
void setup() {
    size(1920,1080);
    frameRate(fr);

    w = new World();
}


void draw(){
    w.act();
    w.draw();
}

void mouseClicked() {
    if (BOMB_MODE) {
        this.w.bomb(mouseX, mouseY, BOMB_SIZE);
    }
    if (SPAWN_MODE) {
        Snek s = new Snek(w, mouseX, mouseY);
        this.w.sneks.add(s);
    }
}


void keyPressed() {
    if (key == 'h') {
        if (w.help == null) {
            w.help = new Help();
        } else {
            w.help = null;
        }
    }
    if (key == 'd') {
        DIAG_MODE = !DIAG_MODE;
    }
    if (key == 's') {
        VAR_SEG_SIZE = !VAR_SEG_SIZE;
    }
    if (key == 'c') {
        CENTER_MODE = !CENTER_MODE;
    }
    if (key == 'g') {
        GRID_MODE = !GRID_MODE;
    }
    if (key == 'l') {
        COLOR_MODE++;
        if (COLOR_MODE>2) {
            COLOR_MODE=0;
        }
    }
    if (key == 'r') {
        w.reset();
    }
    if (key == 'n') {
        CLEAR_BG_MODE = !CLEAR_BG_MODE;
    }
    if (key == 'p') {
        SPAWN_MODE = !SPAWN_MODE;
    }
    if (key == 'a') {
        w.spawn(10);
    }

    if (key == '9') {
        fr+=3;
        frameRate(fr);
    }
    if (key == '0') {
        fr-=3;
        frameRate(fr);
    }
}
