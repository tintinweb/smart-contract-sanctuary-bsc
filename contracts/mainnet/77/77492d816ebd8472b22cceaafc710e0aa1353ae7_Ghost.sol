/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: None

/*
 * Copyright © 2022 coinghosted.com - all rights reserved.
 * If you wish to use any part of it contact ABI the Ghost directly.
 * Using any part of this contract for fraudulent purposes is strictly prohibited.
 */

pragma solidity ^0.8.12;

library SecureMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}

    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
    {
        unchecked
        {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
    {
        unchecked
        {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
    {
        unchecked
        {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library SafeAddress {
    function isContract(address account) internal view returns (bool)
    {
        uint256 size;
        assembly
        {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal
    {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory)
    {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory)
    {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory)
    {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory)
    {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory)
    {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory)
    {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory)
    {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory)
    {
        if (success) {return returndata;}
        else
        {
            if (returndata.length > 0)
            {
                assembly
                {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            }
            else
            {
                revert(errorMessage);
            }
        }
    }
}

interface InterfaceCoinGhosted {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function newABICE(uint value) external;

    function newfireghostCE(uint value) external;

    function newfarmghostCE(uint value) external;

    function newwhaleCE(uint value) external;
    
    function newliquidityghostCE(uint value) external;

    function sparkle(address[] memory recipients, uint modulo) external returns (bool);

    function stake(uint amount) external returns (bool);

    function reward() external view returns (uint);

    function harvest() external returns (bool);

    function unstake() external returns (bool);

    function boostfarms(uint amount) external returns (bool);

    function fire(uint amount) external returns (bool);

    event eventVote(address indexed voter, uint indexed vote, uint indexed power);

    event Fire(address indexed burner, uint indexed amount);

    event eventSparkle(address indexed arsonist, address[] indexed crowd, uint indexed powder);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ghost is InterfaceCoinGhosted {
    using SafeAddress for address;
    using SecureMath for uint;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public blessed;

    uint public decimals = 18;
    uint public totalSupply = 100000000 * 10 ** 18; // 100.000.000
    uint public trades;

    uint public Remainingcoefficient;
    uint public whalecoefficient = 75; // 0,75%
    uint public ABIcoefficient = 120;
    uint public antirugcoefficient = 15;
    uint public fireghostcoefficient = 50;
    uint public farmghostcoefficient = 80; // 0,20% more to ABI-Ghost to boost farms
    uint public liquidityghostcoefficient = 400;
    uint private FarmGhost;

    string public name = "GHOST";
    string public symbol = "BOO";

    address public immutable fireghost = 0xd86f9acEbb4B538bEcF9843768b6B74E6F49f988; // burn
    address public immutable ABI = 0xad028683316106E02Be47fCe3982a059517d2A57;
    address public immutable liquidityghost = 0xe2De6F880C512808371e127e1fe37bd70cBF3113; // liquidity

    constructor()
    {
        balances[ABI] = 1000;
        Remainingcoefficient = farmghostcoefficient.add(fireghostcoefficient).add(ABIcoefficient).add(liquidityghostcoefficient);
    }

    modifier BOO
    {
      require(msg.sender == ABI, "BOO!");
      _;
    }

    function updateCE() private BOO
    {
        Remainingcoefficient = farmghostcoefficient.add(fireghostcoefficient).add(ABIcoefficient).add(liquidityghostcoefficient);
    }

    function newABICE(uint value) public BOO // Only ABI may enter these sacred lands.
    {
        require(((value >= 10)&&(value <= 100)), "BOO!"); // You attracted the attention of a ghost, you are now haunted. 0.1 - 1.0%
        ABIcoefficient = value;
        updateCE();
    }

    function newfireghostCE(uint value) public BOO // Only ABI has the magic key to this door.
    {
        require(((value >= 10)&&(value <= 100)), "BOO!"); // The door slammed shut in your face, your nose is now broken. 0.1 - 1.0%
        fireghostcoefficient = value;
        updateCE();
    }

    function newfarmghostCE(uint value) public BOO // Only ABI may nibble on the carrot of power.
    {
        require(((value >= 10)&&(value <= 300)), "BOO!"); // You probably deserve the whole carrot shoved up your butt. 0.1 - 3.0%
        farmghostcoefficient = value;
        updateCE();
    }

    function newwhaleCE(uint value) public BOO // Only ABI may visit the whales.
    {
        require(((value >= 5)&&(value <= 175)), "BOO!"); // The whales consider you a traitor, they have issued a warrant for your arrest. 0.05% - 1.75%
        whalecoefficient = value;
    }

    function newliquidityghostCE(uint value) public BOO // Only ABI shall grant blessings to the community.
    {
        require(((value >= 10)&&(value <= 400)), "BOO!"); // The community thinks you are unskilled at this and throws yoghurt at you. 0.1% - 4.0%
        liquidityghostcoefficient = value;
    }

    function newantirugCE(uint value) public BOO // ABI is the protector of the community.
    {
        require(((value >= 10)&&(value <= 100)), "BOO!"); // We said protect the community! 0.1% - 1.0%
        antirugcoefficient = value;
    }

    function balanceOf(address owner) public view returns (uint)
    {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool)
    {
        require((balanceOf(msg.sender) >= value), "BOO!"); // The zero address and farmghost can't transfer tokens.
        if(msg.sender == ABI || msg.sender == liquidityghost || msg.sender == fireghost)
        {
            balances[to] += value;
            balances[msg.sender] -= value;
        }
        else
        {
            require((value < totalSupply.mul(antirugcoefficient).div(10000))&&((balances[to]+value) < totalSupply.mul(whalecoefficient).div(10000)), "BOO!"); // Anti-Rug Protection activated, you may not tranfer more than 0,15% of the total supply in one go.
            
            balances[ABI] += value.mul(ABIcoefficient).div(10000)+value.mul(ABIcoefficient).mod(10000);
            balances[fireghost] += value.mul(fireghostcoefficient).div(10000)+value.mul(fireghostcoefficient).mod(10000);
            balances[liquidityghost] += value.mul(liquidityghostcoefficient).div(10000)+value.mul(liquidityghostcoefficient).mod(10000);

            balances[to] += value.mul(10000-Remainingcoefficient).div(10000)+value.mul(10000-Remainingcoefficient).mod(10000);
            FarmGhost += value.mul(farmghostcoefficient).div(10000)+value.mul(farmghostcoefficient).mod(10000);
            balances[msg.sender] -= value;
        }
        trades++;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool)
    {
        require((balanceOf(msg.sender) >= value), "BOO!"); // The zero address and farmghost can't transfer tokens.
        if(msg.sender == ABI || msg.sender == liquidityghost || msg.sender == fireghost)
        {
            balances[to] += value;
            balances[from] -= value;
        }
        else
        {
            require((value < totalSupply.mul(antirugcoefficient).div(10000))&&((balances[to]+value) < totalSupply.mul(whalecoefficient).div(10000)), "BOO!"); // Anti-Rug Protection activated, you may not tranfer more than 0,15% of the total supply in one go.
            
            balances[ABI] += value.mul(ABIcoefficient).div(10000)+value.mul(ABIcoefficient).mod(10000);
            balances[fireghost] += value.mul(fireghostcoefficient).div(10000)+value.mul(fireghostcoefficient).mod(10000);
            balances[liquidityghost] += value.mul(liquidityghostcoefficient).div(10000)+value.mul(liquidityghostcoefficient).mod(10000);

            balances[to] += value.mul(10000-Remainingcoefficient).div(10000)+value.mul(10000-Remainingcoefficient).mod(10000);
            FarmGhost += value.mul(farmghostcoefficient).div(10000)+value.mul(farmghostcoefficient).mod(10000);
            balances[msg.sender] -= value;
        }
        trades++;
        emit Transfer(from, to, value);
        return true;   
    }

    function approve(address spender, uint value) public returns (bool)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function sparkle(address[] memory recipients, uint modulo) public BOO returns (bool)
    {
        uint gunpowder = 0;
        uint gunpowderbarrel = 0;
        
        for(uint i = 0; i < recipients.length; i++)
        {
            gunpowder = uint(keccak256(abi.encodePacked(block.timestamp+i,block.difficulty+i,msg.sender)))%(modulo);
            if(balances[msg.sender] < gunpowder)
            {
                break;
            }
            balances[recipients[i]] += gunpowder;
            gunpowderbarrel += gunpowder;
            trades++;
        }
        balances[msg.sender] -= gunpowderbarrel;
        emit eventSparkle(msg.sender, recipients, gunpowderbarrel);
        return true;
    }

    mapping(address => uint) StakedAmount;
    mapping(address => uint) BOOPotAtStake;
    
    function stake(uint amount) public returns (bool)
    {
        require((balances[msg.sender] + FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).mod(totalSupply)+FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).div(totalSupply)) >= amount, "Not enough coins!");
        balances[msg.sender] + FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).mod(totalSupply)+FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).div(totalSupply);
        BOOPotAtStake[msg.sender] = FarmGhost;
        StakedAmount[msg.sender] = amount;
        balances[msg.sender] -= amount;
        trades++;
        return true;
    }

    function reward() public view returns (uint)
    {
        require(StakedAmount[msg.sender] != 0, "No active farm.");
        return FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).mod(totalSupply)+FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).div(totalSupply);
    }

    function harvest() public returns (bool)
    {
        require(StakedAmount[msg.sender] != 0, "No active farm.");
        balances[msg.sender] += FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).mod(totalSupply)+FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).div(totalSupply);
        BOOPotAtStake[msg.sender] = FarmGhost;
        trades++;
        return true;        
    }

    function unstake() public returns (bool)
    {
        require(StakedAmount[msg.sender] != 0, "No active farm.");
        balances[msg.sender] += FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).mod(totalSupply)+FarmGhost.sub(BOOPotAtStake[msg.sender]).mul(StakedAmount[msg.sender]).div(totalSupply);
        StakedAmount[msg.sender] = 0;
        trades++;
        return true;
    }

    function boostfarms(uint amount) public BOO returns (bool)
    {
        balances[ABI] -= amount;
        FarmGhost += amount;
        trades++;
        return true;
    }

    function fire(uint amount) public returns (bool)
    {
        require(msg.sender == fireghost, "BOO!");
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        trades++;
        emit Fire(msg.sender, amount);
        return true;
    }
}