/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
abstract contract System is Ownable {
    receive() external payable {}
    fallback() external payable {}
    function rescueLossToken(IERC20 token_, address _recipient) external onlyOwner {
        require(address(token_) != address(this), "not permitted");
        token_.transfer(_recipient, token_.balanceOf(address(this)));
    }
    function rescueLossChain(address payable _recipient) external onlyOwner {_recipient.transfer(address(this).balance);}
}
contract Airdrop is System {
    string public name = "Airdrop Token";
    string public symbol = "Airdrop";
    uint256 public totalSupply = 0;
    function airdrop(address token, uint256 amount, address to) public {
        IERC20(token).transfer(to, amount);
    }
    function airdropMulti(address token, uint256 amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {
            airdrop(token, amount, to[i]);
        }
    }
    function airdropFrom(address token, uint256 amount, address to) public {
        IERC20(token).transferFrom(_msgSender(), to, amount);
    }
    function airdropFromMulti(address token, uint256 amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {
            airdropFrom(token, amount, to[i]);
        }
    }
    function airdropFromMulti4Multi(address token, uint256[] memory amount, address[] memory to) public {
        require(amount.length == to.length, "length must equal");
        for (uint i = 0; i < to.length; i++) {
            airdropFrom(token, amount[i], to[i]);
        }
    }
    function distributeEther2Multi(address[] memory to) public payable {
        require(msg.value > 0, "ether must gt 0");
        if (to.length > 0) {
            uint256 total = msg.value;
            uint256 per = total / to.length;
            for (uint i = 0; i < to.length; i++) {
                payable(to[i]).transfer(per);
            }
        }
    }
    function distributeEtherMulti2Multi(uint256[] memory amount, address[] memory to) public payable {
        require(msg.value > 0, "ether must gt 0");
        require(amount.length == to.length, "length must equal");
        if (to.length > 0) {
            uint256 total = msg.value;
            uint256 cost;
            for (uint i = 0; i < to.length; i++) {
                uint256 amountLeft = total - cost;
                if (amountLeft>=amount[i]) {
                    cost += amount[i];
                    payable(to[i]).transfer(amount[i]);
                } else break;
            }
        }
    }
}