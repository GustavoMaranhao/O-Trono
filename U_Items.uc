//=============================================================================
// U_Items
//
// Parent Class of all Iventory items to be added in the InventoryManager
//
// This class in intereacted with in the Inventory manager as well as the MenuScene GUI
// When the player selects the item in the GUI the HUD notifies the inventory manager and tells
// the item in the array that is is bieng focused on. Making it read to be used and call remove inventory at any time
//
// Copyright 2011-2012 Jonathan Vazquez All Rights Reserved.
//=============================================================================
//class that holds the functions and uses of each item

//These classes extending U_Items will be added once a physical pickup is picked up

class U_Items extends Actor abstract;

DefaultProperties
{
}
