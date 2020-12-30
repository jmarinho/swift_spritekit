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
    var map = Array(repeating: Array(repeating: 0, count: 5), count: 5)
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
        
        map = [[0,0,0,0,0],
               [0,0,0,0,0],
               [0,0,1,1,0],
               [0,1,1,0,0],
               [0,0,0,0,0]]
        /*
        map = [[0,0,0,0,0],
               [0,0,1,1,0],
               [0,0,1,0,0],
               [0,0,1,0,0],
               [0,0,0,0,0]]
        */
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
            print("N")
            return map[x][y]
        case .E:
            return map[4-y][x]
        case .S:
            return map[x][y]
        case .W:
            return map[y][4-x]
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
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var squares = [SKShapeNode]()
    //var image = SKSpriteNode(imageNamed: "square.png")
    
    var tab = Array(repeating: Array(repeating: 0, count: 50), count: 100)
    var cur_piece: piece? = nil
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        var iter = 0
        let wait = SKAction.wait(forDuration:0.2)
        let action = SKAction.run {


            if self.cur_piece == nil
            {
                self.cur_piece = piece(pos: CGPoint(x:10, y:50))
                let selector = Int.random(in: 0...5)
                switch selector {
                case 0:
                    self.cur_piece = piece(pos: CGPoint(x:10, y:50))
                case 1:
                    self.cur_piece = square(pos: CGPoint(x:10, y:50))
                case 2:
                    self.cur_piece = line(pos: CGPoint(x:10, y:50))
                case 3:
                    self.cur_piece = ell(pos: CGPoint(x:10, y:50))
                case 4:
                    self.cur_piece = tee(pos: CGPoint(x:10, y:50))
                case 5:
                    self.cur_piece = ess(pos: CGPoint(x:10, y:50))
                    
                default:
                    fatalError("unknown piece type")
                }
            }
            self.cur_piece?.center.y -= 1
            self.print_tab()
            //print ("test print time", iter)
            iter += 1
        }
        run(SKAction.repeatForever(SKAction.sequence([wait,action])))
    }
    
    func touchDown(atPoint pos : CGPoint) {

        print(pos)

        if pos.y < self.size.height*0.2
        {
            self.cur_piece?.rotate()
            print("rotate")
            return
        }
        
        if pos.x > self.size.width/2.0
        {
            self.cur_piece?.center.x+=1
            return
        }
        if pos.x < self.size.width/2.0
        {
            self.cur_piece?.center.x-=1
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
        // Add the image to the scene.

        //image.position = pos
        //self.addChild(image)
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
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
        let sq_size = CGFloat(20)
        
        let square = SKShapeNode(rectOf: CGSize.init(width: sq_size, height: sq_size))
        square.fillColor = color
  
        let xpos = index_x * sq_size
        let ypos = index_y * sq_size
    
        //print("xpos ", xpos)
        square.position = CGPoint(x: xpos, y: ypos)
        
        self.squares.append(square)
        self.addChild(square)
    }
    
    func copy_piece_to_tab()
    {
        let piece_x = self.cur_piece?.center.x ?? 0
        let piece_y = self.cur_piece?.center.y ?? 0
        for index_x in 0...4
        {
            for index_y in 0...4
            {
                let element = self.cur_piece?.get_piece(x: index_x, y: index_y)
                if element! > 0
                {
                    let square_x = piece_x - CGFloat(index_x) + 2.0
                    let square_y = piece_y - CGFloat(index_y) + 2.0
                    self.tab[Int(square_x)][Int(square_y)] = 1
                }
            }
        }
        self.cur_piece=nil
    }
    
    func print_piece()
    {
        let piece_x = self.cur_piece?.center.x ?? 0
        let piece_y = self.cur_piece?.center.y ?? 0
    
        for index_x in 0...4
        {
            for index_y in 0...4
            {
                let element = self.cur_piece?.get_piece(x: index_x, y: index_y)
                if element! > 0
                {
                    let square_x = piece_x - CGFloat(index_x) + 2.0
                    let square_y = piece_y - CGFloat(index_y) + 2.0
                
                    self.print_square(index_x: square_x, index_y: square_y, color: self.cur_piece!.color)
                    if(square_y == 1 || (self.tab[Int(square_x)][Int(square_y-1)] > 0))
                    {
                        copy_piece_to_tab()
                        return
                    }
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
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        //self.squares.removeAll(keepingCapacity: true)
        

    }
}
