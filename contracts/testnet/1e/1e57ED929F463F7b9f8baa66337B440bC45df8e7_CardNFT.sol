/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// admin
abstract contract Adminable is Ownable {
    mapping(address => bool) public isAdmin;

    constructor() {}

    modifier onlyAdmin {
        require(isAdmin[msg.sender], "admin error");
        _;
    }

    function addAdmin(address account) external onlyOwner {
        require(account != address(0), "0 address error");
        isAdmin[account] = true;
    }

    function removeAdmin(address account) external onlyOwner {
        require(account != address(0), "0 address error");
        isAdmin[account] = false;
    }
}


// CardNFT interface
interface ICardNFT {
    function card(address account) external view returns(uint256);
    function mintCard(address account, uint256 grade) external;
    function burnCard(address account) external;
    function cardEteState(address account) external view returns(uint256,uint256);
    function changeCardEteState(address account, uint256 limit, uint256 taked) external;
}


// CardNFT
contract CardNFT is ICardNFT, Adminable {
    string public constant name = "Card NFT";
    string public constant symbol = "Card";
    mapping(address => uint256) private _card;         // 0=not card, 1=glory card, 2=star card.
    mapping(address => eteState) private _cardEteState; // 
    struct eteState {
        uint256 limit;       // ete earn limit.
        uint256 taked;       // ete taked count.
    }
    
    constructor() {}


    event MintCard(address account, uint256 grade);
    event BurnCard(address account);
    event ChangeCardEteState(address account, uint256 limit, uint256 taked, uint256 addLimit, uint256 addTaked);
    

    function card(address account) external override view returns(uint256) {
        return _card[account];
    }

    function mintCard(address account, uint256 grade) external override onlyAdmin {
        require(account != address(0), "zero address error");
        require(grade == 1 || grade == 2, "grade error");
        require(grade > _card[account], "mint error");

        _card[account] = grade;
        emit MintCard(account, grade);
    }

    function burnCard(address account) external override onlyAdmin {
        _card[account] = 0;
        emit BurnCard(account);
    }

    // card set state
    function cardEteState(address account) external override view returns(uint256 limit, uint256 taked) {
        limit = _cardEteState[account].limit;
        taked = _cardEteState[account].taked;
    }

    // change state
    function changeCardEteState(address account, uint256 limit, uint256 taked) external override onlyAdmin {
        eteState storage _userCardEteState = _cardEteState[account];
        _userCardEteState.limit = _userCardEteState.limit + limit;
        _userCardEteState.taked = _userCardEteState.taked + taked;
        emit ChangeCardEteState(account, _userCardEteState.limit, _userCardEteState.taked, limit, taked);
    }

    // take token
    function takeToken(address token, address to, uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransfer(token, to, value);
    }

}