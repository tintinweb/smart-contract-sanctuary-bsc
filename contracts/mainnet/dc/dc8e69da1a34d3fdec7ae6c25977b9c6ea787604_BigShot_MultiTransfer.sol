/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address sender, uint256 value) external returns (bool);

    function allowance(address sender, address spender)
        external
        view
        returns (uint256);

    function transfer(address recepient, uint256 value) external returns (bool);

    function transferFrom(
        address sender,
        address recepient,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 value
    );
}

contract Context {
    constructor() {}

    function _msgsender() internal view returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address internal _Owner;

    event transferOwnerShip(
        address indexed _previousOwner,
        address indexed _newOwner
    );

    constructor() {
        address msgsender = _msgsender();
        _Owner = msgsender;
        emit transferOwnerShip(address(0), msgsender);
    }

    function checkOwner() public view returns (address) {
        return _Owner;
    }

    modifier OnlyOwner() {
        require(_Owner == _msgsender(), "Only owner!");
        _;
    }

    function transferOwnership(address _newOwner) public OnlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "Owner should not be 0 address");
        emit transferOwnerShip(_Owner, _newOwner);
        _Owner = _newOwner;
    }
}

contract BigShot_MultiTransfer is Ownable {
    IBEP20 public bigShotToken;

    event MultiTransfer(address[] userAddress, uint256[] amount);
    event UpdateBigShotToken(address indexed addr);

    receive() external payable {}

    constructor(address _bigShotToken) {
        bigShotToken = IBEP20(_bigShotToken);
    }

    function multiTransfer(
        address[] memory recepientAddress,
        uint256[] memory amount
    ) public OnlyOwner {
        require(recepientAddress.length == amount.length, "Invalid length");
        for (uint8 i; i < recepientAddress.length; i++) {
            require(recepientAddress[i] != address(0), "0 Addr!");
            require(
                bigShotToken.balanceOf(msg.sender) >= amount[i],
                "insufficient funds!"
            );
            require(
                bigShotToken.transferFrom(
                    msg.sender,
                    recepientAddress[i],
                    amount[i]
                ),
                "Tx failed"
            );
        }
        emit MultiTransfer(recepientAddress, amount);
    }

    function updateBigShotToken(address _bigShotToken) public OnlyOwner {
        require(_bigShotToken != address(0), "0 Addr!");
        bigShotToken = IBEP20(_bigShotToken);
        emit UpdateBigShotToken(_bigShotToken);
    }

    function emergencyWithdraw(
        address tokenAddress,
        address _toUser,
        uint256 amount
    ) public OnlyOwner returns (bool status) {
        require(_toUser != address(0), "Invalid Address");
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, "Insufficient balance");
            require(payable(_toUser).send(amount), "Transaction failed");
            return true;
        } else {
            require(
                IBEP20(tokenAddress).balanceOf(address(this)) >= amount,
                "insufficient funds!"
            );
            IBEP20(tokenAddress).transfer(_toUser, amount);
            return true;
        }
    }
}