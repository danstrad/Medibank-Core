package com.garin.pathfinding {
	import com.garin.pathfinding.INode;
	
	/**
	 * A* pathfinding implementation
	 * Based in large part on a tutorial by Phil Chertok
	 * @author Daniel Stradwick "garin"
	 */
	
	public class AStar {
		
		public static var heuristic:Function = AStar.euclidianHeuristic;		
		

		
		public static function findPath(firstNode:INode, destinationNode:INode, connectedNodeFunction:Function):Array {
			var openNodes:Array = [];
			var closedNodes:Array = [];
			
			var testNode:INode;
			var connectedNodes:Array;
			
			var g:Number;
			var h:Number;
			var f:Number;
			
			var l:int;
			var i:int;

			//var travelCost:Number = 1.0;

			var currentNode:INode = firstNode;
			
			currentNode.g = 0;	// initial cost is 0- already here
			currentNode.h = heuristic(currentNode, destinationNode, travelCost); // estimated cost
			currentNode.f = currentNode.g + currentNode.h;	// final cost
		
			
			while (currentNode != destinationNode) {
				
				connectedNodes = connectedNodeFunction(currentNode);
				
				l = connectedNodes.length;
				
				for (i = 0; i < l; i++) {
					testNode = connectedNodes[i];
					if (testNode == currentNode || testNode.traversable == false) continue;
					
					var travelCost:Number = testNode.travelCost;
					
					g = currentNode.g + travelCost; 
					h = heuristic(testNode, destinationNode, travelCost);
					f = g + h;
					
					if (AStar.isOpen(testNode, openNodes) || AStar.isClosed(testNode, closedNodes))	{
						
						if(testNode.f > f) {
							testNode.f = f;
							testNode.g = g;
							testNode.h = h;
							testNode.parentNode = currentNode;
						}
						
					} else {
						testNode.f = f;
						testNode.g = g;
						testNode.h = h;
						testNode.parentNode = currentNode;
						openNodes.push(testNode);
					}
				}
				
				closedNodes.push(currentNode);
				
				if (openNodes.length == 0) 	return null;
	
				openNodes.sortOn('f', Array.NUMERIC);
				currentNode = openNodes.shift() as INode;
			}			
			
			return AStar.buildPath(destinationNode, firstNode);
		}
		
		
		public static function isOpen(node:INode, openNodes:Array):Boolean {
			var l:int = openNodes.length;
			for (var i:int = 0; i < l; ++i) {
				if ( openNodes[i] == node ) return true;
			}			
			return false;			
		}
		
		public static function isClosed(node:INode, closedNodes:Array):Boolean {
			var l:int = closedNodes.length;
			for (var i:int = 0; i < l; ++i) {
				if (closedNodes[i] == node ) return true;
			}
			return false;
		}
		
		
		
		public static function buildPath(destinationNode:INode, startNode:INode):Array {
			var path:Array = [];
			var node:INode = destinationNode;
			path.push(node);
			while (node != startNode) {
				node = node.parentNode;
				path.unshift(node);
			}
			return path;
		}		
		
		
		public static function diagonalHeuristic(node:INode, destinationNode:INode, cost:Number = 1.0, diagonalCost:Number = 1.0):Number {
			var dx:Number = Math.abs(node.x - destinationNode.x);
			var dy:Number = Math.abs(node.y - destinationNode.y);
			var diag:Number = Math.min( dx, dy );
			var straight:Number = dx + dy;
			return diagonalCost * diag + cost * (straight - 2 * diag);
		}

		public static function euclidianHeuristic(node:INode, destinationNode:INode, cost:Number = 1.0):Number {
			var dx:Number = node.x - destinationNode.x;
			var dy:Number = node.y - destinationNode.y;
			return Math.sqrt( dx * dx + dy * dy ) * cost;
		}

		public static function manhattanHeuristic(node:INode, destinationNode:INode, cost:Number = 1.0):Number {
			return Math.abs(node.x - destinationNode.x) * cost + 
				Math.abs(node.y + destinationNode.y) * cost;
		}

	}

}