int noSnek = 5;
int SNEK_SEG_SIZE = 10;
int BORED_AFTER = 70;
int CHANCE_TURN = 65;
int CHANCE_GROW = 95;
int MAX_AGE = 100000;
int MAX_SIZE = 100;

class SnekSeg{
    float x;
    float y;
    float size;
    int life;
    color col;
    boolean head = false;
    Snek daddy;

    public SnekSeg(float x, float y, int life, Snek daddy) {
        this.x=x;
        this.y=y;
        this.life = life;
        this.size = SNEK_SEG_SIZE;
        this.daddy = daddy;
        this.col = daddy.col;
    }
    boolean dead() {
        return this.life<0;
    }
    void act() {
        this.life--;
    }
    void draw() {
        if (this.dead()) {
            return;
        }
        if(this.life != this.daddy.size) {
            noStroke();
        }
        fill(this.col);
        rect(this.x, this.y, this.size, this.size);
    }
}

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
    ArrayList<SnekSeg> segs = new ArrayList<SnekSeg>();

    public Snek() {
        this.age = 0;

        //random start position
        float x = random(0,width);
        float y = random(0,height);
        this.pos = new PVector(x,y);

        //random size
        this.size = int(random(0,10));
        
        //random timer
        this.bored_timer = int(random(0,BORED_AFTER));
        //random color
        this.col = color(random(100),random(50,100), random(0,200));

        // random speed
        PVector speed = new PVector(0, SNEK_SEG_SIZE);
        this.speed = speed;
        random_direction();
    }

    void addSeg() {
        print("++ ");
        this.newSegs++;
        this.size++;
        for (SnekSeg s : this.segs) {
            s.life++;
        }
    }

    void random_direction() {
        print("|> ");
        if (random(0,2)>1) {
            this.speed.rotate(radians(90));
        } else {
            this.speed.rotate(radians(-90));
        }
        
        // float speed = max(abs(this.dx), abs(this.dy));

        // if (random(0,2)>1) {
        //     speed = speed*-1;
        // } 
        // if (random(0,2)>1) {
        //     this.dx = speed;
        //     this.dy = 0;
        // } else {
        //     this.dy=speed;
        //     this.dx = 0;
        // }
    }

    void move() {
        this.pos.add(this.speed);
        // x+=dx;
        // y+=dy;
        SnekSeg s = new SnekSeg (
            this.x(), this.y(), this.size, this
        );
        this.segs.add(s);
    }
    boolean dead() {
        return this.age > MAX_AGE;
    }

    void act() {
        this.move();
        for (SnekSeg seg : this.segs) {
            seg.act();
        }
        ArrayList<SnekSeg> rm = new ArrayList<SnekSeg>();
        for (SnekSeg seg : this.segs) {
            if (seg.dead()) {
                rm.add(seg);
            }
        }
        for (SnekSeg seg : rm) {
            this.segs.remove(seg);
        }
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

    void draw() {
        for (SnekSeg seg : this.segs) {
            seg.draw();
        }
    }
}


class World {
    ArrayList<Snek> sneks = new ArrayList<Snek>();

    public World() {
        for (int i = noSnek; i>0; i--) {
            this.sneks.add(new Snek());
        }
    }

    void constrain_to_world(Snek s) {
        if (s.x() > width) {
            s.sx(0);
        } else if (s.x() < 0) {
            s.sx(width);
        }
        if (s.y() > height) {
            s.sy(0);
        } else if (s.y() < 0) {
            s.sy(width);
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
        background(20);
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
