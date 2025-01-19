int noSnek = 50;
int SNEK_SEG_SIZE = 10;
int BORED_AFTER = 70;
int CHANCE_TURN = 65;
int CHANCE_GROW = 95;
int MAX_AGE = 100000;
int MAX_SIZE = 100;
color bg = color(10);
int BOMB_SIZE = 200;

boolean DIAG_MODE = true;
boolean BOMB_MODE = true;
boolean SHOW_BOMB = true;

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

class Snek extends PosObject {
    // PVector pos;

    int size;
    PVector speed = new PVector(0,SNEK_SEG_SIZE);

    int age;
    int bored_timer = int(random(0,BORED_AFTER));

    int newSegs = 0;
    color col;
    ArrayList<PVector> segs = new ArrayList<PVector>();
    World w;

    public Snek(World w) {
        this.age = 0;
        this.w = w;

        //random start position
        float x = random(0,width);
        float y = random(0,height);
        this.pos = new PVector(x,y);

        //random size
        this.size = 1;
        this.segs.add(this.pos.copy());
        //random timer
        this.bored_timer = int(random(0,BORED_AFTER));
        //random color
        this.col = color(random(100),random(50,100), random(0,200));

        // random speed
        PVector speed = new PVector(0, SNEK_SEG_SIZE);
        this.speed = speed;
        random_direction();
    }
    void createSegs() {
      this.newSegs = this.size;
      for (int i=0; i< this.size; i++) {
        this.move();
      }
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
            turnDeg = currDeg + currDeg % 90;
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
        this.segs.add(head);
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

    void drawSeg(PVector p) {
        noStroke();
        fill(this.col);
        rect(p.x, p.y, SNEK_SEG_SIZE, SNEK_SEG_SIZE);
    }

    void draw() {
        for (PVector seg : this.segs) {
            drawSeg(seg);
        }
    }

    boolean collides(PVector head, float headSize) {
        for (PVector seg: this.segs) {
            if (seg.dist(head)< SNEK_SEG_SIZE + headSize) {
                // print(String.format("S %f,%f COLLIDES w %f,%f",seg.x, seg.y, head.x, head.y));
                return true;
            }
        }
        return false;
    }
}


class World {
    ArrayList<Snek> sneks = new ArrayList<Snek>();

    void bomb(float x, float y, float size) {
        println("BOMB");
        Snek s = new Snek(this);
        PVector vec = new PVector(0,1);
        PVector center = new PVector(x,y);
        for (int r = 0; r<360; r+=1) {
            vec.rotate(radians(r));
            for (float dist=1; dist < size; dist+=5) {
                PVector target = PVector.add(vec.setMag(dist),center);
                s.segs.add(target);
            }
        }
        s.age = MAX_AGE;
        if (!SHOW_BOMB) {

        }
        this.sneks.add(s);

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