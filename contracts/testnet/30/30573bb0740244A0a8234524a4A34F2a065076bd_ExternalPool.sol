// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./SignatureVerifier.sol";
import "./WithSigner.sol";

contract ExternalPool is Ownable, Pausable, WithSigner {
    using SignatureVerifier for bytes32;
    struct userData {
        address previusOwner;
        bool isBlock;
    }
    mapping(bytes32 => bool) usedKeys;
    mapping(IERC20 => bool) public isTokenWhitelisted;
    mapping(address => bool) public isAddressWhitelisted;
    mapping(IERC20 => mapping(address => uint256)) public totalDeposits;
    mapping(IERC20 => mapping(address => uint256)) public lastDepositAmount;
    mapping(IERC20 => mapping(address => uint256)) public totalWitdraws; //can be more with totalDeposits

    modifier onlyWhitelistedTokens(IERC20 _token) {
        require(
            isTokenWhitelisted[_token],
            "MARKETPLACE: Token address not whitelisted"
        );
        _;
    }

    event Deposit(IERC20 _token, uint256 _amount, address _from, bool houseWallet);
    event Unlock(IERC20 _token, uint256 _amount, address _to, bool houseWallet);

    // WithSigner(_signer) add in constructor
    constructor(IERC20[] memory _tokens,address _signer) WithSigner(_signer) {
        whitelistTokens(_tokens);
    }

    function whitelistTokens(IERC20[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isTokenWhitelisted[_tokens[i]] = true;
        }
    }

    function blacklistTokens(IERC20[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isTokenWhitelisted[_tokens[i]] = false;
        }
    }


    function whitelistAddress(address[] memory _Address) public onlyOwner {
        for (uint256 i = 0; i < _Address.length; i++) {
            isAddressWhitelisted[_Address[i]] = true;
        }
    }

    function blacklistAddress(address[] memory _Address) public onlyOwner {
        for (uint256 i = 0; i < _Address.length; i++) {
            isAddressWhitelisted[_Address[i]] = false;
        }
    }

    //Deposit
    function deposit(
        IERC20 _token, 
        uint256 _depositAmount,        
        bytes memory _signature,
        bytes32 _idempotencyKey
    )
        public
        onlyWhitelistedTokens(_token)
        returns (bool)
    {   
        bool house =  isAddressWhitelisted[msg.sender];
        require(_token.transferFrom(msg.sender, address(this), _depositAmount));
        bool used = getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bool isPermitValid = validateData(_signature,_idempotencyKey, _depositAmount);
        require(isPermitValid, "No signer match");


        totalDeposits[_token][msg.sender] += _depositAmount;
        lastDepositAmount[_token][msg.sender] = _depositAmount;

        setUsedKeys(_idempotencyKey);
        emit Deposit(_token, _depositAmount, msg.sender, house);
        return true;
    }

    //unlock
    function unLock(
        IERC20 _token,
        uint256 _unLockAmount,
        bytes memory _signature,
        bytes32 _idempotencyKey
    ) public onlyWhitelistedTokens(_token) returns (bool) {
        bool house =  isAddressWhitelisted[msg.sender];
        bool used = getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bool isPermitValid = validateData(_signature,_idempotencyKey, _unLockAmount);
        require(isPermitValid, "No signer match");
        if(house){
            require( totalDeposits[_token][msg.sender] >= _unLockAmount, "No tienes balances suficientes para retirar");
            totalDeposits[_token][msg.sender] -= _unLockAmount;
        }
        totalWitdraws[_token][msg.sender] += _unLockAmount;
        _token.transfer(msg.sender, _unLockAmount);

        setUsedKeys(_idempotencyKey);
        emit Unlock(_token, _unLockAmount, msg.sender, house);
        return true;
    }

    function getUsedKeys(bytes32 _key) public view onlyOwner returns (bool) {
        return usedKeys[_key];
    }

    function setUsedKeys(bytes32 _key) public onlyOwner {
        usedKeys[_key] = true;
    }

    function validateData(
        bytes memory _signature,
        bytes32 _idempotencyKey,
        uint _amount
    ) public view returns (bool) {
        bool used = getUsedKeys(_idempotencyKey);
        require(!used, "FACTORY: Permit already used");
        bytes32 hash = getHash(_idempotencyKey, address(this), _amount);
        bytes32 messageHash = getEthSignedHash(hash);
        bool isPermitValid = verify(signer(), messageHash, _signature);
        return isPermitValid;
    }

    function getHash(
        bytes32 _idempotencyKey,
        address contractID,
        uint _amount
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(_idempotencyKey, contractID, _amount)
            );
    }

    function getEthSignedHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verify(
        address signer,
        bytes32 messageHash,
        bytes memory _signature
    ) public pure returns (bool) {
        return messageHash.getSigner(_signature) == signer;
    }
}