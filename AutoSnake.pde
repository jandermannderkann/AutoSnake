
int noSnek = 60;
int SNEK_SEG_SIZE = 15;
int BORED_AFTER = 10;
int CHANCE_TURN = 25;
int CHANCE_GROW = 95;
int MAX_AGE = 100000;
int MAX_SIZE = 100;


int TURN_RADIUS = 60;


int GAP_SIZE = 0;

int fr = 30;
color bg = color(10);
color LAST_SEG_COL = color(10);


int BOMB_SIZE = 200;

boolean RECT_MODE =  false;
boolean VARIABLE_TURNS =  false;
boolean VARYING_BOREDNESS =  false;
boolean GRID_MODE = true;
boolean SPAWN_MODE = false;
boolean STOP_MODE = true;
boolean STOP = false;
int SPAWN_COUNT = 20;
boolean BOMB_MODE = false;

boolean DIAG_MODE = false;
boolean TURN_RESET_MODE = false;
boolean SHOW_BOMB = true;
boolean CLEAR_BG_MODE = true;

boolean VAR_SEG_SIZE = true;
int COLOR_MODE = 2;
boolean CENTER_MODE = true;

int textSize = 19;


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
        background(bg);
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
    textSize(textSize);
    
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
    if (STOP_MODE) {
        STOP=!STOP;
        if (STOP) {
            noLoop();
        } else {loop();}
    }
}


void keyPressed() {
    if (key == 'h') {
        if (w.help == null) {
            w.help = new Help(new PVector(width/2, height/2));
        } else {
            w.help = null;
        }
    }
    if (key == 'd') {
        DIAG_MODE = !DIAG_MODE;
    }
    if (key == 'b') {
        BOMB_MODE = !BOMB_MODE;
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
        if (COLOR_MODE>4) {
            COLOR_MODE=0;
        }
    }
    if (key == 'r') {
        w.reset();
    }
    if (key == 'n') {
        CLEAR_BG_MODE = !CLEAR_BG_MODE;
    }
    if (key == 'a') {
        w.spawn(SPAWN_COUNT);
    }
    if (key == 'p') {
        SPAWN_MODE = !SPAWN_MODE;
    }
    if (!SPAWN_MODE) {
        if (key == '+') {
            SNEK_SEG_SIZE ++;
        }
        if (key == '-') {
            SNEK_SEG_SIZE --;
        }
    }else {
        if (key == '+') {
            SPAWN_COUNT +=2;
        }
        if (key == '-') {
            SPAWN_COUNT -=2;
        }
    }
    if (key == '[') {
        TURN_RADIUS*=2;
    }
    if (key == ']') {
        TURN_RADIUS/=2;;
    }

    if (key == ',') {
        fr+=3;
        frameRate(fr);
    }
    if (key == '.') {
        fr-=3;
        frameRate(fr);
    }
}
