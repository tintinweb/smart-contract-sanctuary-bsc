// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "./libraries.sol";

////////////////////////////////////////////////////////////////
//// This is the MiddleMan smart contract for iPay platform ////
////////////////////////////////////////////////////////////////

contract Plugin is Context, Ownable {

    using SafeMath for uint256;
    using Address for address;

    struct Tokenomics {
        address [] to; // where the token will be distributed
        uint256 [] share; // amount in _total
        uint256 total; // 100%
        IBEP20 token; // Token address
        string platform;
        address owner;
        bytes32 key;
    }
    // ID => Tokenomics
    mapping(uint256 => Tokenomics) _tokens;

    struct Payeenomics {
        IStaking stakingContract; // Token address
        uint256 total;
        uint256 staking;
    }
    // ID => User => Payeenomics
    mapping(uint256 => mapping(address => Payeenomics)) payeenomics;

    uint256 index;

    // Events
    event TokenomicsAdded(uint256 ID);
    event TokenomicsUpdated(uint256 ID);
    event Distributed(uint256 ID, address sender, address receiver, uint256 amount, string nonce);

    // Add new token payment method
    function addTokenomics(string memory _platform, address _token, uint256 _total, address [] memory _to, uint [] memory _share, bytes32 _key) external onlyOwner {
        uint256 _ID = index++;
        require (address(_tokens[_ID].token) == address(0), "The ID is already taken."); // DO NOT OVERRIDE
        require (bytes(_platform).length > 0, "Please provide your platform name.");
        require (_to.length == _share.length, "The number of _share and _to does not match.");
        uint256 total = _total;
        for (uint i = 0; i < _share.length; i ++) 
        {
            require( total > _share[i], "INVALID_SHARE_AMOUNT");
            total -= _share[i];
        }

        _tokens[_ID].platform = _platform;
        _tokens[_ID].token = IBEP20(_token);
        _tokens[_ID].total = _total;
        _tokens[_ID].to = _to;
        _tokens[_ID].share = _share;
        _tokens[_ID].owner = msg.sender;
        _tokens[_ID].key = _key;

        emit TokenomicsAdded(_ID);
    }

    // Tokenomics getter by ID
    function getTokenomics(uint256 _ID) external view returns(Tokenomics memory) {
        return _tokens[_ID];
    }

    // Tokenmocis setter by ID
    function updateTokenomics(uint256 _ID, string memory _platform, uint256 _total, address [] memory _to, uint [] memory _share, bytes32 _key) external onlyOwner {
        require (address(_tokens[_ID].token) != address(0), "INVALID_ID"); // DO NOT OVERRIDE
        require (address(_tokens[_ID].owner) == msg.sender, "You are not the owner of this platform");
        require (_to.length == _share.length, "The number of _share and _to does not match.");
        uint256 total = _total;
        for (uint i = 0; i < _share.length; i ++) {
            require( total> _share[i], "INVALID_SHARE_AMOUNT");
            total -= _share[i];
        }

        _tokens[_ID].platform = _platform;
        _tokens[_ID].total = _total;
        _tokens[_ID].to = _to;
        _tokens[_ID].share = _share;
        _tokens[_ID].key = _key;

        emit TokenomicsUpdated(_ID);
    }

    // Distributes
    function distribute(uint _ID, uint256 _amount, address _to, string memory nonce) external returns(bytes32 key) {
        require (address(_tokens[_ID].token) != address(0), "INVALID_ID"); // DO NOT OVERRIDE

        Tokenomics memory tokenomics = _tokens[_ID];
        uint256 amount = _amount;

        // First, distribute
        for (uint i = 0; i < tokenomics.share.length; i ++)
        {
            uint dAmount = _amount * tokenomics.share[i] / tokenomics.total;
            TransferHelper.safeTransferFrom(address(tokenomics.token), _msgSender(), tokenomics.to[i], dAmount);
            amount -= dAmount;
        }

        // Second, make the payment
        Payeenomics memory payee = payeenomics[_ID][_to];
        if (payee.total == 0)
        { // no payeenomics
            TransferHelper.safeTransferFrom(address(tokenomics.token), _msgSender(), _to, amount); // Transfer to User if remains
        } else {
            uint256 staking = amount * payee.staking / payee.total;

            TransferHelper.safeTransferFrom(address(tokenomics.token), _msgSender(), address(this), staking); // Transfer to User if remains
            tokenomics.token.approve(address(payee.stakingContract), staking);
            payee.stakingContract.depositFromContract(staking, _to); // Staking the percentage of token
            
            if (staking < amount) 
                TransferHelper.safeTransferFrom(address(tokenomics.token), _msgSender(), _to, amount - staking); // Transfer to User if remains
        }
        emit Distributed(_ID, _msgSender(), _to, amount, nonce);

        return _tokens[_ID].key;
    }

    // Return Token Address from ID
    function tokenFromID(uint _ID) external view returns(address) {
        return address(_tokens[_ID].token);
    }

    function setPayeenomics (uint256 _ID, address _stakingContract, uint256 total, uint256 staking) external {
        require (total > staking, "INVALID_STAKING_AMOUNT");
        require(_stakingContract != address(0), "INVALID_STAKING_CONTRACT_ADDRESS");
        payeenomics[_ID][msg.sender] = Payeenomics(IStaking(_stakingContract), total, staking);
    }

    function getPayeenomics (uint256 _ID, address _payee) external view returns(Payeenomics memory){
        return payeenomics[_ID][_payee];
    }

}