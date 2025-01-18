int noSnek = 50;
int SNEK_SEG_SIZE = 10;
int BORED_AFTER = 100;
int CHANCE_TURN = 95;
int CHANCE_GROW = 80;
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

class Snek {
    float x;
    float y;
    int size;
    float dx =0;
    float dy =0;
    
    int age;
    int bored_timer = int(random(0,BORED_AFTER));

    int newSegs = 0;
    color col;
    ArrayList<SnekSeg> segs = new ArrayList<SnekSeg>();

    public Snek() {
        this.x = random(0,width);
        this.y = random(0,height);
        this.size = 1;

        this.bored_timer = 0;
        this.age = 0;
        this.col = color(random(100),random(50,100), random(0,200));


        // initial speed
        float speed = SNEK_SEG_SIZE* random(0,SNEK_SEG_SIZE/10);
        if (random(0,2)>1) {
            speed = speed *-1;
        } 
        if (random(0,2)>1) {
            this.dx = speed;
            this.dy = speed/10 + random(0,1);
        } else {
            this.dy = speed;
            this.dx = speed/10 + random(0,1);
        }
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
        
        float speed = max(abs(this.dx), abs(this.dy));

        if (random(0,2)>1) {
            speed = speed*-1;
        } 
        if (random(0,2)>1) {
            this.dx = speed;
            this.dy = speed/10;
        } else {
            this.dy=speed;
            this.dx = speed/10;
        }
    }

    void move(float dx, float dy) {
        x+=dx;
        y+=dy;
        SnekSeg s = new SnekSeg (
            x, y, this.size, this
        );
        this.segs.add(s);
    }

    void act() {
        if (this.age > MAX_AGE) {
            return;
        }
        this.move(this.dx, this.dy);
        for (SnekSeg seg : this.segs) {
            seg.act();
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
    void act() {
        for (Snek s : this.sneks) {
            s.act();
        }
        for (Snek s : this.sneks) {
            if (s.x > width) {
                s.x=0;
            } else if (s.x < 0) {
                s.x = width;
            }
            if (s.y > height) {
                s.y=0;
            } else if (s.y < 0) {
                s.y = width;
            }
        }

    }
    void draw() {
        background(20);
        for (Snek s : this.sneks) {
            s.draw();
        }
        // line(i,i,0,0);
    }
}

World w;
void setup() {
    size(1920,1080);
    // frameRate(5);
    w = new World();
}


void draw(){
    w.act();
    w.draw();
}
