package model;

class Player {
    public var id: String = "";
    public var name: String = "";
    public var color: String = "";
    public var admin: Bool = false;

    public function new() {
        
    }

    static function fromData(data: Dynamic):Player {
        var player: Player = new Player();
        player.update(data);
        return player;
    }

    function update(data: Dynamic) {
        this.id = data.id;
        this.name = data.name;
        this.color = data.color;
        this.admin = data.admin;
    }

    function toJSON() {
        return {
            name: this.name,
            color: this.color
        }
    }
}