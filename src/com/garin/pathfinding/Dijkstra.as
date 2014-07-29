package com.garin.pathfinding {
	
	public class Dijkstra {   
		
		private var visited:Array;
		private var distance:Array;
		private var previousNode:Array;
		public var startNode:Number;
		private var map:Array;
		private var infiniteDistance:Number;
		private var numberOfNodes:Number;
		private var bestPath:Number;
		private var nodesLeft:Array;
		
		public static const NO_CONNECTION:int = 99999999;
		
		private var pathsFound:Boolean = false;			// we already crunched the numbers
		
		
		public function Dijkstra(ourMap:Array, startNode:Number) {
			this.infiniteDistance = NO_CONNECTION;
			this.startNode = startNode;
			this.distance = [];
			this.previousNode = [];
			this.visited = [];
			this.map = ourMap;
			this.numberOfNodes = this.map[0].length;
			this.bestPath = 0;
			this.nodesLeft = [];
		}
		
		
		
		public function findShortestPaths():void {
			
			for (var i:int = 0; i < this.numberOfNodes; i++) {
				
				if (i == this.startNode) {
					this.visited[i] = 1;
					this.distance[i] = 0;
				} else {
					this.visited[i] = 0;
					this.distance[i] = this.map[this.startNode][i];
				}
				 
				//this.previousNode[i] = 0;
				this.previousNode[i] = this.startNode;
			}   
			
			
			// loop variable to make sure we dont hang when we can't find a path
			const MAX_ITERATIONS:int = 300;
			
			var iterations:int = 0;
			
			while ((this.somethingLeft(this.visited)) && (iterations < MAX_ITERATIONS)) {
				 this.nodesLeft = this.nodesNotVisited(this.visited);
				 this.bestPath = this.findBestPath(this.distance, this.nodesLeft);
				 this.updateDistanceAndPrevious(this.bestPath);
				 this.visited[this.bestPath] = 1;
				 
				 iterations++;
			}
			
			
			if (iterations >= MAX_ITERATIONS) {
				// we timed out, invalidate the results?
				
			} 
				
			pathsFound = true;
		}
		
		
		private function somethingLeft(ourVisited:Array):Boolean {
			for (var i:int=0; i < this.numberOfNodes; i++) {
				 if (!(ourVisited[i])) {
					  return true;
				 }
			}
			return false;
		}
		
		private function nodesNotVisited(ourVisited:Array):Array {
			var selectedArray:Array = [];
			for (var i:int = 0; i < this.numberOfNodes; i++) {
				 if (!(ourVisited[i])) {
					  selectedArray.push(i);
				 }
			}
			return selectedArray;
		}
		
		private function findBestPath(ourDistance:Array, ourNodesLeft:Array):Number {
			var bestPath:int = this.infiniteDistance;
			var bestNode:int = 0;	// is this a problem?
			for (var i:int = 0; i < ourNodesLeft.length; i++) {
				 if (ourDistance[ourNodesLeft[i]] < bestPath) {
					  bestPath = ourDistance[ourNodesLeft[i]];
					  bestNode = ourNodesLeft[i];
				 }
			}
			return bestNode;
		}
		
		private function updateDistanceAndPrevious(ourBestPath:Number):void {
			for (var i:int = 0; i < this.numberOfNodes; i++) {
				 if (!(this.map[ourBestPath][i] == this.infiniteDistance) || (this.map[ourBestPath][i] == 0)) {
					  if ((this.distance[ourBestPath] + this.map[ourBestPath][i]) < this.distance[i]) {
						   this.distance[i] = this.distance[ourBestPath] + this.map[ourBestPath][i];
						   this.previousNode[i] = ourBestPath;
					  }
				 }
			}
		}
		
		
		
		public function findShortestPathTo(targetNode:Number, maxNodes:int):Array {
			if (!pathsFound)	this.findShortestPaths();
			
			// results
			var ourShortestPath:Array = [];
				
			var endNode:int;
			var currNode:int = targetNode;

			ourShortestPath.push(targetNode);
			
			var nodes:int = 1;
			
			while ((endNode != this.startNode) && (nodes < maxNodes)) {
			   ourShortestPath.push(this.previousNode[currNode]);
			   endNode = this.previousNode[currNode];
			   currNode = this.previousNode[currNode];
			   nodes++;
			}
			
			if (nodes >= maxNodes)			ourShortestPath.length = 0; // we can't find a valid path
			else 							ourShortestPath.reverse();
			
			return ourShortestPath;
		}		



		private function getResults():void {
			var ourShortestPath:Array = [];
				
			for (var i:int = 0; i < this.numberOfNodes; i++) {
				  ourShortestPath[i] = [];
				  var endNode:int;
				  var currNode:int = i;
				  ourShortestPath[i].push(i);
				  while(endNode != this.startNode) {
					   ourShortestPath[i].push(this.previousNode[currNode]);
					   endNode = this.previousNode[currNode];
					   currNode = this.previousNode[currNode];
				  }
				  ourShortestPath[i].reverse();
				  trace("---------------------------------------");
				  trace("The shortest distance from the startNode: "+this.startNode+
						", to node "+i+": is -> "+this.distance[i]);
				  trace("The shortest path from the startNode: "+this.startNode+
						", to node "+i+": is -> "+ourShortestPath[i]);
				  trace("---------------------------------------");
			 }

		}


	}
}
