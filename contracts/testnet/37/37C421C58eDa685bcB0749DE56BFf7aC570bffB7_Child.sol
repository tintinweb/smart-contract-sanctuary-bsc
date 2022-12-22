/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract Child {
  string public constant NAME = "Bill";
  string public constant AGE = "0";
  uint256 public constant TOYS = 3;
  string public constant familyName = "Doors";
}

contract DelayedChild {
    string public name;
    uint256 public toys;

    event ChildNamed(string newName);
    event ChildNewToys(uint256 oldToyQty, uint256 newToyQty);

    function nameChild(string calldata _name) external {
        name = _name;

        emit ChildNamed(_name);
    }

    function giveToys(uint256 _numToys) external {
        uint256 oldToyQty = toys;
        
        toys += _numToys;

        emit ChildNewToys(oldToyQty, toys);
    }

    function takeToys(uint256 _numToys) external {
        uint256 oldToyQty = toys;

        if(_numToys > toys) {
            toys = 0;
        } else {
            toys -= _numToys;
        }

        emit ChildNewToys(oldToyQty, toys);
    }
}

contract Parent {
  event NewChild(address child);

  function bringNewLife() external {
    Child child = new Child();
    emit NewChild(address(child));
  }
}