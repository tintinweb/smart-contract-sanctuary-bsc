// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
 
import "./PausableUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./IERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";

import "./Initializable.sol";

import "./ITreasure.sol";

contract Summoner is Initializable,  PausableUpgradeable, OwnableUpgradeable  {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    address private _nftAddress;

    mapping(uint256 => bool) usedNonces;
    mapping (address => bool) public whitelistedSigner;

    event BuyNFT(
        uint256 episodeNumber, 
        uint256 price, 
        address indexed buyer,
        bytes sig,
        bytes walletSig,
        uint256 tokenId
    );

    function initialize(address nftAddress ) public initializer {
        __Pausable_init();
        __Ownable_init();

        _nftAddress = nftAddress;
      
    }

    // user should approve this contract to spent its token
    function buyNFT(uint256 episodeNumber, uint256 seed , uint256 nonce, bytes memory sig, bytes memory walletSig ) external  whenNotPaused returns (uint256) {
        require(!usedNonces[nonce],"Used nonce");
        usedNonces[nonce] = true;

        require(isValidData(episodeNumber, seed, nonce, sig, walletSig)==true,"Invalid data");

        address buyer = _msgSender();
        address tokenAddress = ITreasure(_nftAddress).tokenAddress();
        uint256 price = ITreasure(_nftAddress).getEpisodeTreasurePrice(episodeNumber);
        address rewardPoolAddress = ITreasure(_nftAddress).rewardPoolAddress();

        require(IERC20Upgradeable(tokenAddress).allowance(buyer,address(this))>=price, "Token amount allowance is not enough to buy treasure");
        IERC20Upgradeable(tokenAddress).safeTransferFrom(buyer, rewardPoolAddress, price);
        
        uint256 tokenId = ITreasure(_nftAddress).buyTreasure(buyer, episodeNumber, seed);

        emit BuyNFT(episodeNumber, price, buyer, sig, walletSig, tokenId);
        return tokenId;
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function isValidData(uint256 episodeNumber, uint256 seed, uint256 nonce, bytes memory sig, bytes memory walletSig) private view returns(bool){
        address _walletAddress = _msgSender();
        
        bytes32 message = prefixed(
            keccak256(abi.encodePacked(episodeNumber, _walletAddress, seed, nonce, sig))
        );

        // verify that the wallet signed the message
        require(recoverSigner(message, walletSig)==_msgSender(),"Not signed by the user"); 

        bytes32 signedMessage = keccak256(abi.encodePacked(episodeNumber, _walletAddress, seed, nonce));

        require(whitelistedSigner[recoverSigner(signedMessage, sig)]==true, "Not signed by the authority");

        return true;
    }

    function setSigner(address _signer, bool _whitelisted) external onlyOwner {
        require(whitelistedSigner[_signer] != _whitelisted,"Invalid value for signer");
        whitelistedSigner[_signer] = _whitelisted;
    }

    function isSigner(address _signer) external view returns (bool) {
        return whitelistedSigner[_signer];
    }
    


    function recoverSigner(bytes32 message, bytes memory sig) public pure returns (address) {
       uint8 v;
       bytes32 r;
       bytes32 s;
       (v, r, s) = splitSignature(sig);
       return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (uint8, bytes32, bytes32) {
       require(sig.length == 65);

       bytes32 r;
       bytes32 s;
       uint8 v;

       assembly {
           // first 32 bytes, after the length prefix
           r := mload(add(sig, 32))
           // second 32 bytes
           s := mload(add(sig, 64))
           // final byte (first byte of the next 32 bytes)
           v := byte(0, mload(add(sig, 96)))
       }
 
       return (v, r, s);
    }
}