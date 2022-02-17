/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

pragma solidity 0.5.17;

interface Locker {
    function transfer(address _to, uint256 _amount) external returns (bool);
    event Transfer(address _tokenContract, address _recipient, uint256 value);
}

contract Context {
    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Timelocker is Locker, Context, Ownable {

    uint256 _end;
    uint256 _result;
    uint256 _amount;
    address _tokenContract;
    address _recipient;
    constructor() public {
        _end = 100;
        _amount = 2;
        _tokenContract = 0xb3F496bE0aEcC147D37bD1c73A027399d550094F;
    }


    modifier timerOver {
        if(now <= _result) {
            Locker tokenContract = Locker(_tokenContract);
            tokenContract.transfer(msg.sender, _amount);
        } else {
            revert();
        }
        _;
    }

    function withdraw() internal onlyOwner {
        _result = _end+now;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        emit Transfer(sender, recipient, amount);
    }

    function getTimeLeft() public timerOver returns(uint) {
        return _result-now;
    }

}