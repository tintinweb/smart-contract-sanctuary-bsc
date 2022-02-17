/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

pragma solidity ^0.4.21;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Airdropper contract
 * @dev see https://yangwenbo.com/articles/erc20-airdropper.html
 */
contract AirdropperWithIgnore is Ownable {

    function balanceOfToken(address from, address _tokenAddr) public view returns (uint256) {
        return ERC20(_tokenAddr).balanceOf(from);
    }

    function multisendFromIgnoreHolders(address _tokenAddr, address from, address[] dests, uint256 values) public onlyOwner returns (uint256) {
        uint256 amount = values * dests.length;
        uint256 balances =  balanceOfToken(from ,_tokenAddr);
        require(balances > amount);
        uint256 i = 0;
        while (i < dests.length) {
           uint256 tokenHold = balanceOfToken(dests[i] ,_tokenAddr);
           if (tokenHold == 0) {
                ERC20(_tokenAddr).transferFrom(from, dests[i], values);
           }
           i += 1;
        }
        return(i);
    }

    function multisendIgnoreHolders(address _tokenAddr, address[] dests, uint256 values) public onlyOwner returns (uint256) {
        uint256 amount = values * dests.length;
        uint256 balances =  balanceOfToken(msg.sender ,_tokenAddr);
        require(balances > amount);
        uint256 i = 0;
        while (i < dests.length) {
            uint256 tokenHold = balanceOfToken(dests[i] ,_tokenAddr);
            if (tokenHold == 0) {
                ERC20(_tokenAddr).transferFrom(msg.sender, dests[i], values);
            }
            i += 1;
        }
        return(i);
    }


    function multisendFrom(address _tokenAddr, address from, address[] dests, uint256 values) public onlyOwner returns (uint256) {
        uint256 amount = values * dests.length;
        uint256 balances =  balanceOfToken(from ,_tokenAddr);
        require(balances > amount);
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(_tokenAddr).transferFrom(from, dests[i], values);
           i += 1;
        }
        return(i);
    }

    function multisend(address _tokenAddr, address[] dests, uint256 values) public onlyOwner returns (uint256) {
        uint256 amount = values * dests.length;
        uint256 balances =  balanceOfToken(msg.sender ,_tokenAddr);
        require(balances > amount);
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(_tokenAddr).transferFrom(msg.sender, dests[i], values);
           i += 1;
        }
        return(i);
    }

    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }
}