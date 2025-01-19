int noSnek = 50;
int SNEK_SEG_SIZE = 10;
int BORED_AFTER = 70;
int CHANCE_TURN = 65;
int CHANCE_GROW = 95;
int MAX_AGE = 100000;
int MAX_SIZE = 100;
color bg = color(10);
int BOMB_SIZE = 200;

boolean DIAG_MODE = false;
boolean TURN_RESET_MODE = false;
boolean BOMB_MODE = true;
boolean SHOW_BOMB = true;

boolean VAR_SEG_SIZE = false;
boolean CENTER_MODE = false;




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

class SnekSeg extends PosObject {
    // PVector pos;
    float size;

    public SnekSeg(PVector pos, float size) {
        this.pos = pos;
        this.size = size - random(0, SNEK_SEG_SIZE/3);
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
    // ArrayList<PVector> segs = new ArrayList<PVector>();
    // ArrayList<float> segSize = new ArrayList<float>();

    public Snek(World w) {
        this.age = 0;
        this.w = w;

        //random start position
        float x = int(random(0,width/SNEK_SEG_SIZE))*SNEK_SEG_SIZE;
        float y = int(random(0,height/SNEK_SEG_SIZE))*SNEK_SEG_SIZE;
        this.pos = new PVector(x,y);

        //random size
        this.size = 1;
        this.segs.add(new SnekSeg(this.pos.copy(), SNEK_SEG_SIZE));

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
        this.segs.add( new SnekSeg(head, SNEK_SEG_SIZE));
        // println(String.format("Moved to %f,%f by speed %f,%f",head.x, head.y, this.speed.x, this.speed.y));

        if (this.newSegs > 0) {
            this.newSegs -= 1;
        } else {
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

    void drawSeg(PVector p, float size) {
        if (CENTER_MODE) rectMode(CENTER);
        else rectMode(CORNER);
        noStroke();
        fill(this.col);
        rect(p.x, p.y, size, size);
    }

    void draw() {
        for (SnekSeg seg: this.segs) {
            drawSeg(seg.pos, seg.size);
        }
    }

    boolean collides(PVector head, float headSize) {
        for (SnekSeg seg: this.segs) {
            if (seg.pos.dist(head) <= SNEK_SEG_SIZE/2 + headSize/2) {
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
        for (int i = noSnek; i>0; i--) {
            this.sneks.add(new Snek(this));
        }
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
        background(bg);
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
    frameRate(60);

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
}
