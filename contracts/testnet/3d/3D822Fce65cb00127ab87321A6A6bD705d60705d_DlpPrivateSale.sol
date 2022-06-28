/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

//SPDX-License-Identifier: no

pragma solidity 0.7.6;
pragma abicoder v2;

interface IBEP20 {
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);
}

struct PrivateSaleEvent {
    uint256 startedAt;
    uint256 endedAt;
    uint256 unlockTime;
    uint256 soldAmount;
    uint256 minBnbAmount;
    uint256 maxBnbAmount;
    uint256 bnbRate;
    address coinContractAddress;
    IBEP20 coinContract;
}

struct ClaimTokens {
    uint256 amount;
    uint256 releaseDate;
}

// 1654626574,1664626574,10,1,10,10,0xd9145CCE52D386f254917e481eB44e9943F39138

contract DlpPrivateSale {
    mapping (address => bool) _owners;
    PrivateSaleEvent private _event;
    mapping (address => uint256) _purchases;
    mapping (address => ClaimTokens[]) _claimTokens;


    constructor() {
        _owners[msg.sender] = true;
    }

    function addOwner(address user) public {
        _addOwner(user);
    }

    function removeOwner(address user) public {
        _removeOwner(user);
    }

    function start(
        uint256 startedAt,
        uint256 endedAt,
        uint256 unlockTime,
        uint256 minBnbAmount,
        uint256 maxBnbAmount,
        uint256 bnbRate,
        address coinContractAddress
    ) public returns (PrivateSaleEvent memory e) {
        require(_owners[msg.sender] == true, "Only owner can create event");

        return _start(startedAt, endedAt, unlockTime, minBnbAmount, maxBnbAmount, bnbRate, coinContractAddress);
    }

    function getEvent() public view returns (PrivateSaleEvent memory e) {
        return _event;
    }

    function contractBalance() public view returns (uint256 bnb, uint256 coin) {

        uint256 bnbBalance = address(this).balance;

        if(address(_event.coinContract) == address(0)) {
            return (bnbBalance, 0);
        }

        return (bnbBalance, _event.coinContract.balanceOf(address(this)));
    }

    function withdraw() public {
        _withdraw();
    }

    function buy() public payable {
        _buy();
    }

    function claim() public {
        _claimFor(msg.sender);
    }

    function getClaimTokens() public view returns (ClaimTokens[] memory claimTokens) {
        return _claimTokens[msg.sender];
    }

    function isOwner(address addr) public view returns (bool active) {
        if(addr == address(0)) {
            return _owners[msg.sender];
        }

        return _owners[addr];
    }

    function _addOwner(address user) private {
        require(_owners[msg.sender] == true, "Only owner can use this method");
        _owners[user] = true;
    }

    function _removeOwner(address user) private {
        require(_owners[msg.sender] == true, "Only owner can use this method");
        require(user != msg.sender, "You cannot remove yourself");
        _owners[user] = false;
    }

    function _start(
        uint256 startedAt,
        uint256 endedAt,
        uint256 unlockTime,
        uint256 minBnbAmount,
        uint256 maxBnbAmount,
        uint256 bnbRate,
        address coinContractAddress
    ) private returns (PrivateSaleEvent memory e) {
        require(coinContractAddress != address(0), "Specify coin contract addr");
        require(address(_event.coinContract) == address(0), "Smart contract already used for sale");

        IBEP20 coinContract = IBEP20(coinContractAddress);
        uint256 selfContractBalance = coinContract.balanceOf(address(this));

        require(bnbRate > 0, "BNB Rate cannot be less or equal than zero");
        require(selfContractBalance > 0, "Coin balance must be greater than zero. Deposit it please");
        require(selfContractBalance / bnbRate > 1, "Incorrect rate. Insufficient balance");
        require(startedAt < endedAt, "Started date cannot be less than ended");
        require(maxBnbAmount > minBnbAmount, "Max amount should be greater than min");

        _event = PrivateSaleEvent({
            startedAt: startedAt,
            endedAt: endedAt,
            soldAmount: 0,
            unlockTime: unlockTime,
            minBnbAmount: minBnbAmount,
            maxBnbAmount: maxBnbAmount,
            bnbRate: bnbRate,
            coinContractAddress: coinContractAddress,
            coinContract: coinContract
        });

        return _event;
    }

    function _withdraw() private {
        require(block.timestamp > _event.endedAt, "Event should be end");
        require(_owners[msg.sender], "Only owner can withdraw");

        address payable _to = payable(msg.sender);
        _to.transfer(address(this).balance);

        if(address(_event.coinContract) != address(0)) {
            uint256 balance = _event.coinContract.balanceOf(address(this));
            _event.coinContract.transfer(_to, balance);
        }
    }

    function _buy() private {
        uint256 amount = msg.value;
        uint256 purchased = _purchases[msg.sender];
        uint256 tokensToBuy = amount / _event.bnbRate;
        
        require(amount >= _event.minBnbAmount, "Amount should be greater than min");
        require(amount + purchased <= _event.maxBnbAmount, "Amount should be less than max");
        require(_event.startedAt < block.timestamp, "Event is not started yet");
        require(_event.endedAt > block.timestamp, "Event already closed");
        require(address(_event.coinContract) != address(0), "Event no coin");

        uint256 coinContractBalance = _event.coinContract.balanceOf(address(this));

        require(tokensToBuy > 0, "Cannot buy 0 coins");
        require(amount <= coinContractBalance - _event.soldAmount, "Insufficient amount");

        _event.soldAmount += tokensToBuy;
        _purchases[msg.sender] += amount;
        _claimTokens[msg.sender].push(ClaimTokens({
            amount: tokensToBuy,
            releaseDate: block.timestamp + _event.unlockTime
        }));
    }

    function _claimFor(address addr) private {
        ClaimTokens[] storage claimTokens = _claimTokens[addr];

        for(uint256 i = 0; i < claimTokens.length; i++ ) {
            if(claimTokens[i].releaseDate < block.timestamp && claimTokens[i].amount > 0) {
                _event.coinContract.transfer(msg.sender, claimTokens[i].amount);
                delete _claimTokens[addr][i];
            }
        }
    }
}