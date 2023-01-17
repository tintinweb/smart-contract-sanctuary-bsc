/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC1155 {
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

contract Zion_Transporter is Ownable {
    using SafeMath for uint256;
    address recipientA; // me
    address recipientB; // bro
    uint256 minFeeAmount;

    struct Params20 {
        address token_contract;
        address to;
        uint256 amount;
    }

    struct Params721 {
        address token_contract;
        address to;
        uint256 tid;
    }

    struct Params1155 {
        address token_contract;
        address to;
        uint256 tid;
        uint256 amount;
    }

    constructor (address _recipientA, address _recipientB) {
        recipientA = _recipientA;
        recipientB = _recipientB;
    }

    function transfer20(Params20[] memory datas) public payable {
        require(msg.value >= minFeeAmount.mul(datas.length), "Not enough fee!");

        for (uint256 i = 0; i < datas.length; i++) {
            Params20 memory data = datas[i];

            IERC20(data.token_contract).transferFrom(
                msg.sender,
                data.to,
                data.amount
            );
        }

        payable(recipientB).transfer(address(this).balance.div(2));
        payable(recipientA).transfer(address(this).balance);
    }

    function transfer721(Params721[] memory datas) public payable {
        require(msg.value >= minFeeAmount.mul(datas.length), "Not enough fee!");

        for (uint256 i = 0; i < datas.length; i++) {
            Params721 memory data = datas[i];

            IERC721(data.token_contract).transferFrom(
                msg.sender,
                data.to,
                data.tid
            );
        }

        payable(recipientB).transfer(address(this).balance.div(2));
        payable(recipientA).transfer(address(this).balance);
    }

    function transfer1155(Params1155[] memory datas) public payable {
        require(msg.value >= minFeeAmount.mul(datas.length), "Not enough fee!");

        for (uint256 i = 0; i < datas.length; i++) {
            Params1155 memory data = datas[i];

            IERC1155(data.token_contract).safeTransferFrom(
                msg.sender,
                data.to,
                data.tid,
                data.amount
            );
        }

        payable(recipientB).transfer(address(this).balance.div(2));
        payable(recipientA).transfer(address(this).balance);
    }

    function withdraw(address payable to, uint256 amount) external onlyOwner {
        to.transfer(amount);
    }

    function updateRecipientA(address _recipientA) external onlyOwner {
        recipientA = _recipientA;
    }

    function updateRecipientB(address _recipientB) external onlyOwner {
        recipientB = _recipientB;
    }
    
    function updateMinFeeAmount(uint256 _amount) external onlyOwner {
        minFeeAmount = _amount;
    }
}