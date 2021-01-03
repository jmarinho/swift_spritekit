//
//  GameScene.swift
//  tetris
//
//  Created by Jose Marinho on 26/12/2020.
//

import SpriteKit
import GameplayKit

class piece {
    var center: CGPoint
    static let map_size = 5
    var map: [[Int]]
    var color: UIColor
    private enum Heading {
        case N, E, S, W
    }
    private var rotation: Heading
    init(pos: CGPoint)
    {
        rotation = Heading.N
        center = pos
        color = UIColor(displayP3Red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        
        map = Array(repeating: Array(repeating: 0, count: piece.map_size), count: piece.map_size)
        
        map = [[0,0,0,0,0],
               [0,0,0,0,0],
               [0,0,1,1,0],
               [0,1,1,0,0],
               [0,0,0,0,0]]
    }
    
    func rotate()
    {
        switch self.rotation {
        case .N:
            self.rotation = .E
        case .E:
            self.rotation = .S
        case .S:
            self.rotation = .W
        case .W:
            self.rotation = .N
        }
    }
    
    func get_piece(x: Int, y: Int) -> Int
    {
        switch self.rotation {
        case .N:
            return map[x][y]
        case .E:
            return map[y][piece.map_size-x-1]
        case .S:
            return map[piece.map_size-x-1][y]
        case .W:
            return map[piece.map_size-y-1][piece.map_size-x-1]
        }
    }
}

class square: piece
{
    override init(pos: CGPoint)
    {
        super.init(pos: pos)
        color = UIColor(displayP3Red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        map = [[0,0,0,0,0],
               [0,0,1,1,0],
               [0,0,1,1,0],
               [0,0,0,0,0],
               [0,0,0,0,0]]
    }
    override func rotate() {
        return
    }
}

class line: piece
{
    override init(pos: CGPoint)
    {
        super.init(pos: pos)
        color = UIColor(displayP3Red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)

        map = [[0,0,1,0,0],
               [0,0,1,0,0],
               [0,0,1,0,0],
               [0,0,1,0,0],
               [0,0,1,0,0]]
    }
}

class ell: piece
{
    override init(pos: CGPoint)
    {
        super.init(pos: pos)
        color = UIColor(displayP3Red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)

        map = [[0,0,0,0,0],
               [0,0,1,1,0],
               [0,0,1,0,0],
               [0,0,1,0,0],
               [0,0,0,0,0]]
    }
}

class tee: piece
{
    override init(pos: CGPoint)
    {
        super.init(pos: pos)
        color = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

        map = [[0,0,0,0,0],
               [0,0,1,0,0],
               [0,1,1,1,0],
               [0,0,0,0,0],
               [0,0,0,0,0]]
    }
}

class ess: piece
{
    override init(pos: CGPoint)
    {
        super.init(pos: pos)
        color = UIColor(displayP3Red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)

        map = [[0,0,0,0,0],
               [0,0,0,0,0],
               [0,1,1,0,0],
               [0,0,1,1,0],
               [0,0,0,0,0]]
    }
}

class GameScene: SKScene {
    
    private var squares = [SKShapeNode]()
    
    var tab = Array(repeating: Array(repeating: 0, count: 60), count: 15)
    var cur_piece: piece? = nil
    var next_piece: piece? = nil
    
    var tab_num_x_square: Int = 0
    var tab_num_y_square: Int = 0
    
    let sq_size: CGFloat = CGFloat(15)
    var tab_x_off: CGFloat = CGFloat(0)
    let tab_y_off = CGFloat(40)
    var tab_x_end: CGFloat = CGFloat(0)
    
    var score = 0
    
    func get_next_piece() -> piece
    {
        let initial_pos = CGPoint(x: CGFloat(self.tab_num_x_square/2), y: CGFloat(self.tab_num_y_square - piece.map_size))
        
        let selector = Int.random(in: 0...5)
            
        switch selector {
        case 0:
            return piece(pos: initial_pos)
        case 1:
            return square(pos: initial_pos)
        case 2:
            return line(pos: initial_pos)
        case 3:
            return ell(pos: initial_pos)
        case 4:
            return tee(pos: initial_pos)
        case 5:
            return ess(pos: initial_pos)
                
        default:
            fatalError("unknown piece type")
        }
    }
    
    func check_lines()
    {
        let full_count = tab.count-1
        
        for index_y in 0...tab[0].count-1
        {
            var cur_count = 0
            for index_x in 0...tab.count-1
            {
                if tab[Int(index_x)][Int(index_y)] > 0
                {
                    cur_count += 1
                }
            }
            if cur_count == full_count
            {
                self.score += 1
                
                /* move all lines downward */
                for fill_y in index_y...tab[0].count-2
                {
                    for fill_x in 0...tab.count-1
                    {
                        tab[fill_x][fill_y] = tab[fill_x][fill_y+1]
                    }
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {

        tab_num_x_square = tab.count
        tab_num_y_square = tab[0].count
        
        let tab_x_size = sq_size * CGFloat(tab_num_x_square)
        tab_x_off = (self.size.width - tab_x_size)/2.0
        
        tab_x_end = tab_x_off + tab_x_size
        
        self.cur_piece = get_next_piece()
        self.next_piece = get_next_piece()
        
        assert(tab_x_off > 0, "tab size too small, check sq_size")
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        var iter = 0
        let wait = SKAction.wait(forDuration:0.2)
        let action = SKAction.run {

            
            if(self.check_colision(delta_x: 0, delta_y: -1))
            {
                self.print_tab()
                self.copy_piece_to_tab()
                return
            }
            else
            {
                self.cur_piece?.center.y -= 1
            }
            
            self.print_tab()
            //print ("test print time", iter)
            iter += 1
        }
        run(SKAction.repeatForever(SKAction.sequence([wait,action])))
    }
    
    func print_stat_piece(x: Int, y: Int)
    {
        let sq_size = CGFloat(10)
        
        for index_x in 0...piece.map_size-1
        {
            for index_y in 0...piece.map_size-1
            {
                let element = self.next_piece?.map[index_x][index_y]
                if element! > 0
                {
                    let xpos = CGFloat(index_x) * sq_size + CGFloat(x)
                    let ypos = CGFloat(index_y) * sq_size + CGFloat(y)
                
                    let square = SKShapeNode(rectOf: CGSize.init(width: sq_size, height: sq_size))
                    square.fillColor = self.next_piece!.color
                    square.position = CGPoint(x: xpos, y: ypos)
                    
                    self.squares.append(square)
                    self.addChild(square)
                }
            }
        }
        
    }
    
    func print_stats()
    {
        let lvl = self.score/10
        
        let lvl_lbl = SKLabelNode()
        lvl_lbl.text = "level \(lvl)"
        lvl_lbl.position = CGPoint(x: tab_x_end, y: 800)
        lvl_lbl.horizontalAlignmentMode = .left
        
        let score_lbl = SKLabelNode()
        score_lbl.text = "score \(self.score)"
        score_lbl.position = CGPoint(x: tab_x_end, y: 750)
        score_lbl.horizontalAlignmentMode = .left
        
        let next_lbl = SKLabelNode()
        next_lbl.text = "next piece"
        next_lbl.position = CGPoint(x: tab_x_end, y: 700)
        next_lbl.horizontalAlignmentMode = .left
        
        addChild(lvl_lbl)
        addChild(score_lbl)
        addChild(next_lbl)
    }
    
    func print_boundaries()
    {
        let top_y = tab_y_off + sq_size * CGFloat(self.tab_num_y_square)
        let bottom_y = tab_y_off
        let left_x = self.tab_x_off
        let right_x = self.tab_x_off + sq_size * CGFloat(self.tab_num_x_square)
        
        var boundaries = SKShapeNode()
        var boundary_line = CGMutablePath()
        boundary_line.move(to: CGPoint(x: left_x, y: top_y))
        boundary_line.addLine(to: CGPoint(x: left_x, y: bottom_y))
        boundary_line.addLine(to: CGPoint(x: right_x, y: bottom_y))
        boundary_line.addLine(to: CGPoint(x: right_x, y: top_y))
        boundaries.path = boundary_line
        boundaries.strokeColor = SKColor.green
        addChild(boundaries)
    }
    
    func check_colision(delta_x: Int, delta_y: Int) -> Bool
    {
        
        let center_x = self.cur_piece!.center.x
        let center_y = self.cur_piece!.center.y
        
        let x_left_boundary = 0
        let x_right_boundary = tab.count
        
        for index_x in 0...piece.map_size-1
        {
            for index_y in 0...piece.map_size-1
            {
                if self.cur_piece!.get_piece(x: index_x, y: index_y) == 0
                {
                    continue
                }
                
                let pos_x = center_x + CGFloat(index_x) + CGFloat(delta_x)
                let pos_y = center_y + CGFloat(index_y) + CGFloat(delta_y)
                
                if pos_x == CGFloat(x_left_boundary) || pos_x == CGFloat(x_right_boundary)
                {
                    return true
                }
                
                if pos_y == 0
                {
                    return true
                }
                
                if self.tab[Int(pos_x)][Int(pos_y)] > 0
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    func touchDown(atPoint pos : CGPoint) {

        print(pos)

        if (self.cur_piece==nil)
        {
            return
        }
        
        if pos.y < self.size.height*0.2
        {
            self.cur_piece?.rotate()
            print("rotate")
            return
        }

        if pos.y > self.size.height*0.8
        {
            while !check_colision(delta_x: 0, delta_y: -1)
            {
                self.cur_piece?.center.y -= 1
            }
            return
        }
        
        if pos.x > self.size.width/2.0
        {
            if(!check_colision(delta_x: 1, delta_y: 0))
            {
                self.cur_piece?.center.x+=1
            }
            
            return
        }
 
        if pos.x < self.size.width/2.0
        {
            if(!check_colision(delta_x: -1, delta_y: 0))
            {
                self.cur_piece?.center.x-=1
            }
            return
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        //let image = SKSpriteNode(imageNamed: "square.png")
        let skView = SKView()
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        self.scaleMode = .resizeFill
    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    var framecount = 0

    func print_square(index_x: CGFloat, index_y: CGFloat, color: UIColor)
    {
        /*
         * This function translates the tab coordinates to the Scene coordinates.
         * Each square has a sq_size length. The tab has an x and a y offset from the
         * boundaries of the SKScene
         *
         *
         * tab_x_off = self.size.x - (sq_size * tab_num_x_square) / 2
         */
        

        
        let square = SKShapeNode(rectOf: CGSize.init(width: sq_size, height: sq_size))
        square.fillColor = color
  
        let xpos = tab_x_off + index_x * sq_size
        let ypos = tab_y_off + index_y * sq_size
    
        //print("xpos ", xpos)
        square.position = CGPoint(x: xpos, y: ypos)
        
        self.squares.append(square)
        self.addChild(square)
    }
    
    func copy_piece_to_tab()
    {
        let piece_x = self.cur_piece!.center.x
        let piece_y = self.cur_piece!.center.y
        for index_x in 0...piece.map_size-1
        {
            for index_y in 0...piece.map_size-1
            {
                let element = self.cur_piece?.get_piece(x: index_x, y: index_y)
                if element! > 0
                {
                    let square_x = piece_x + CGFloat(index_x)
                    let square_y = piece_y + CGFloat(index_y)
                    self.tab[Int(square_x)][Int(square_y)] = 1
                }
            }
        }
        self.check_lines()

        self.cur_piece = self.next_piece
        self.next_piece = get_next_piece()
    }
    
    func print_piece()
    {
        let piece_x = self.cur_piece!.center.x
        let piece_y = self.cur_piece!.center.y
    
        for index_x in 0...piece.map_size-1
        {
            for index_y in 0...piece.map_size-1
            {
                let element = self.cur_piece?.get_piece(x: index_x, y: index_y)
                if element! > 0
                {
                    let square_x = piece_x + CGFloat(index_x)
                    let square_y = piece_y + CGFloat(index_y)
                
                    self.print_square(index_x: square_x, index_y: square_y, color: self.cur_piece!.color)
                }
            }
        }
    }
    
    func print_tab()
    {
        self.removeAllChildren()
        self.squares.removeAll()
        
        framecount += 1

        print_piece()
        
        for (index_x,column) in tab.enumerated()
        {
            for (index_y, _) in column.enumerated()
            {
                if tab[index_x][index_y] > 0
                {
                    let color = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

                    self.print_square(index_x: CGFloat(index_x), index_y: CGFloat(index_y), color: color)
                }
            }
        }
        self.print_boundaries()
        self.print_stats()
        self.print_stat_piece(x: Int(self.tab_x_end + 20), y: 650)

    }
    override func update(_ currentTime: TimeInterval) {
    }
}
