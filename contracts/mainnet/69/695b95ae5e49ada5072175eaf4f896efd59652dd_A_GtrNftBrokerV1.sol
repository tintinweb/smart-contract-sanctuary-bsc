/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library TransferHelper {
    function safeTransferFrom(address token, address from, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF'); }
    function safeTransfer(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST'); }
    function safeApprove(address token, address to, uint256 value) internal { (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value)); require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA'); }
    function safeTransferETH(address to, uint256 value) internal { (bool success, ) = to.call{value: value}(new bytes(0)); require(success, 'STE'); }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _transferOwnership(_msgSender()); }
    function owner() public view virtual returns (address) { return _owner; }
    modifier onlyOwner() { require(owner() == _msgSender(), "Ownable: caller is not the owner");  _; }
    function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }
    function transferOwnership(address newOwner) public virtual onlyOwner { require(newOwner != address(0), "Ownable: new owner is the zero address"); _transferOwnership(newOwner); }
    function _transferOwnership(address newOwner) internal virtual { address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner); }
}

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor() { _paused = false; }
    function paused() public view virtual returns (bool) { return _paused; }
    modifier whenNotPaused() { require(!paused(), "Pausable: paused"); _; }
    modifier whenPaused() { require(paused(), "Pausable: not paused"); _; }
    function _pause() internal virtual whenNotPaused { _paused = true; emit Paused(_msgSender()); }
    function _unpause() internal virtual whenPaused { _paused = false; emit Unpaused(_msgSender()); }
}


contract A_GtrNftBrokerV1 is Ownable, Pausable {
    
    IERC721Enumerable public _nftContractAddress;
    IERC20 public _nftPriceTokenAddress;
    uint256 public _nftPrice;
    
    address public _nftFeeAddress0;
    address public _nftFeeAddress1;
    address public _nftFeeAddress2;
    uint64 public _nftFeeAmount1;
    uint64 public _nftFeeAmount2;
    uint64 public _nftFeeDivisor1;
    uint64 public _nftFeeDivisor2;


    //events
    event NftSold(address contractAddress, uint256 tokenId, address contributor, address beneficiary, uint256 price, string ref);

    constructor() {
        _nftContractAddress = IERC721Enumerable(0xFE5976756A2b9990f5A831763b7634861bc83FD4);
        _nftPriceTokenAddress = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        _nftPrice = 1359 * 10 ** 18;

        _nftFeeAddress0 = 0xf0408ab1d301631A6B06540848A623291c1Ba02a;
        _nftFeeAddress1 = 0xF7f3341b8b3c8C1EdE5870a8EF34Ea1d13557a51;
        _nftFeeAddress2 = 0x642112906102918EAc8023fF787F8c79c531398e;
        _nftFeeAmount1 = 500;
        _nftFeeAmount2 = 500;
        _nftFeeDivisor1 = 10000;
        _nftFeeDivisor2 = 10000;
    }

    function purchaseNft(address beneficiary, string calldata ref) external whenNotPaused {
        require(_nftContractAddress.balanceOf(address(this)) > 0, "OUT_OF_STOCK");
        require(_nftPriceTokenAddress.allowance(msg.sender, address(this)) >= _nftPrice, "ALLOWANCE_LOW");

        //pull funds from buyer's wallet into contract
        TransferHelper.safeTransferFrom(address(_nftPriceTokenAddress), msg.sender, address(this), _nftPrice);
        
        //seperately transfer funds from contract to fee wallets, that way the fee wallets don't show directly in user's wallet
        uint256 fee1 = (_nftFeeAmount1 > 0 && _nftFeeDivisor1 > 0) ? _nftPrice * _nftFeeAmount1 / _nftFeeDivisor1 : 0;
        TransferHelper.safeTransfer(address(_nftPriceTokenAddress), _nftFeeAddress1, fee1);
        uint256 fee2 = (_nftFeeAmount2 > 0 && _nftFeeDivisor2 > 0) ? _nftPrice * _nftFeeAmount2 / _nftFeeDivisor2 : 0;
        TransferHelper.safeTransfer(address(_nftPriceTokenAddress), _nftFeeAddress2, fee2);
        uint256 remaining = _nftPrice - fee1 - fee2;
        TransferHelper.safeTransfer(address(_nftPriceTokenAddress), _nftFeeAddress0, remaining);

        //transfer NFT
        uint256 tokenId = _nftContractAddress.tokenOfOwnerByIndex(address(this), 0);
        _nftContractAddress.safeTransferFrom(address(this), beneficiary, tokenId);

        //emit event
        emit NftSold(address(_nftContractAddress), tokenId, msg.sender, beneficiary, _nftPrice, ref);
    }

    function getStockLevel() external view returns (uint256 amount) {
        return _nftContractAddress.balanceOf(address(this));
    }


    //
    // ADMIN FUNCTIONS
    //

    function setSaleSettings(IERC721Enumerable nftContractAddress, IERC20 nftPriceTokenAddress, uint256 nftPrice) external onlyOwner {
        _nftContractAddress = nftContractAddress;
        _nftPriceTokenAddress = nftPriceTokenAddress;
        _nftPrice = nftPrice;
    }

    function setFeeSettings(address feeAddress0, address feeAddress1, address feeAddress2, uint64 feeAmount1, uint64 feeAmount2, uint64 feeDivisor1, uint64 feeDivisor2) external onlyOwner {
        _nftFeeAddress0 = feeAddress0;
        _nftFeeAddress1 = feeAddress1;
        _nftFeeAddress2 = feeAddress2;
        _nftFeeAmount1 = feeAmount1;
        _nftFeeAmount2 = feeAmount2;
        _nftFeeDivisor1 = feeDivisor1;
        _nftFeeDivisor2 = feeDivisor2;        
    }

    //default withdrawal functions
    function withdrawToken(address destinationAddress, IERC20 token, uint256 amount) external onlyOwner {
        if (address(token) == address(0)) {
            (bool success, ) = destinationAddress.call{value: (amount == 0 ? address(this).balance : amount)}(new bytes(0)); 
            require(success, 'STE');
        } else {
            (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, destinationAddress, (amount == 0 ? token.balanceOf(address(this)) : amount))); 
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
        }
    }

    function withdrawNft(address destination, address tokenAddress, uint256 tokenId) external onlyOwner {
        IERC721Enumerable(tokenAddress).safeTransferFrom(address(this), destination, tokenId);
    }

    function withdrawAllNfts(address destination, IERC721Enumerable tokenAddress) external onlyOwner {
        uint256 totalNfts = tokenAddress.balanceOf(address(this));
        for (uint256 i = 0; i < totalNfts; i++) {
            uint256 tokenId = _nftContractAddress.tokenOfOwnerByIndex(address(this), 0);
            tokenAddress.safeTransferFrom(address(this), destination, tokenId);
        }
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
    receive() external payable {}
}