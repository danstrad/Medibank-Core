package com.garin.pathfinding {
	
	/**
	 * Pathfinding node interface
	 * Based in large part on a tutorial by Phil Chertok
	 * @author Daniel Stradwick "garin"
	 */
	
	public interface INode {
		function get f():Number;
		function get g():Number;
		function get h():Number;
		function get x():Number;
		function get y():Number;
		function get parentNode():INode;
		function get traversable():Boolean;
		function set f(value:Number):void;
		function set g(value:Number):void;
		function set h(value:Number):void;
		function set parentNode(value:INode):void;
		function set traversable(value:Boolean):void;
		function get travelCost():Number;
		function set travelCost(value:Number):void;		
	}
	
}