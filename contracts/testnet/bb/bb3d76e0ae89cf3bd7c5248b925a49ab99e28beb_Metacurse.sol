// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import './Ownable.sol';
import './IERC1155_EXT.sol';
import './SafeMath.sol';
import './SafeERC20.sol';
import './Math.sol';
import './ERC1155Receiver.sol';
import './ReentrancyGuard.sol';

contract Metacurse is Ownable, ERC1155Receiver, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    IERC1155_EXT public nft;
    IERC20 public token;

    /* NFT Events */
    event AirdropNFT(address indexed fromAdd, address indexed toAdd, uint256 tokenId, uint256 quantity);
    event DepositNFT(address indexed fromAdd, address indexed toAdd, uint256 tokenId, uint256 quantity);
    event WithdrawNFT(address indexed fromAdd, address indexed toAdd, uint256 tokenId, uint256 quantity);

    /* Tokens Events */
    event AirdropToken(address indexed fromAdd, address indexed toAdd, uint256 quantity);
    event DepositToken(address indexed fromAdd, address indexed toAdd, uint256 quantity);
    event WithdrawToken(address indexed fromAdd, address indexed toAdd, uint256 quantity);

    /* BNB Events */
    event AirdropBNB(address indexed fromAdd, address indexed toAdd, uint256 quantity);
    event DepositBNB(address indexed fromAdd, address indexed toAdd, uint256 quantity);
    event WithdrawBNB(address indexed fromAdd, address indexed toAdd, uint256 quantity);

    constructor(address _nftAddress, address _tokenAddress) {
        require(_nftAddress.isContract() && _nftAddress != address(0) && _nftAddress != address(this));
        require(_tokenAddress.isContract() && _tokenAddress != address(0) && _tokenAddress != address(this));

        nft = IERC1155_EXT(_nftAddress);
        token = IERC20(_tokenAddress);
    }

    /* NFT Functionality */

    function withdrawNft(
        uint256 _tokenID,
        address _to,
        uint256 _quantity
    ) external onlyOwner {
        nft.safeTransferFrom(address(this), _to, _tokenID, _quantity, '0x');
        emit WithdrawNFT(address(this), _to, _tokenID, _quantity);
    }

    function depositNft(uint256 _tokenID, uint256 _quantity) external {
        nft.safeTransferFrom(msg.sender, address(this), _tokenID, _quantity, '0x');
        emit DepositNFT(msg.sender, address(this), _tokenID, _quantity);
    }

    function depositMultiNft(uint256[] memory _tokenId, uint256[] memory _quantity) external onlyOwner {
        depositMultiNFT(_tokenId, _quantity);
    }

    function depositMultiNFT(uint256[] memory _tokenId, uint256[] memory _quantity) internal {
        require(_tokenId.length == _quantity.length, 'Length not Equal');

        for (uint256 i = 0; i < _quantity.length; i++) {
            nft.safeTransferFrom(msg.sender, address(this), _tokenId[i], _quantity[i], '0x');
            emit DepositNFT(msg.sender, address(this), _tokenId[i], _quantity[i]);
        }
    }

    function NFTAirdrop(
        uint256[] memory _tokenId,
        address[] memory _to,
        uint256[] memory _quantity
    ) external onlyOwner {
        dropNFT(_tokenId, _to, _quantity);
    }

    function dropNFT(
        uint256[] memory _tokenId,
        address[] memory _to,
        uint256[] memory _quantity
    ) internal {
        require(_tokenId.length == _to.length && _to.length == _quantity.length, 'Length not Equal');

        for (uint256 i = 0; i < _to.length; i++) {
            nft.safeTransferFrom(address(this), _to[i], _tokenId[i], _quantity[i], '0x');
            emit AirdropNFT(address(this), _to[i], _tokenId[i], _quantity[i]);
        }
    }

    /* Token Functionality */

    function depositToken(uint256 _amount) external nonReentrant {
        require(_amount <= token.balanceOf(msg.sender), 'Token Balance of user is less');
        require(token.allowance(msg.sender, address(this)) >= _amount, 'BEP20: Token Not Approved for Sale');
        token.transferFrom(msg.sender, address(this), _amount);
        emit DepositToken(msg.sender, address(this), _amount);
    }

    function withdrawToken(address _toAddress, uint256 _amount) external onlyOwner nonReentrant {
        token.transfer(_toAddress, _amount);
        emit WithdrawToken(address(this), _toAddress, _amount);
    }

    function withdrawMultiTokens(address[] memory _recipients, uint256[] memory _amount)
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {
        uint256 total = 0;
        require(_recipients.length == _amount.length);
        for (uint256 j = 0; j < _amount.length; j++) {
            total = total.add(_amount[j]);
        }
        require(token.balanceOf(address(this)) >= total, 'Token Balance of contract is less than the total Airdrop');

        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0));
            require(token.transfer(_recipients[i], _amount[i]));
            emit AirdropToken(address(this), _recipients[i], _amount[i]);
        }
        return true;
    }

    /* BNB Functionality */

    function withdrawMultiBnb(uint256[] memory _amount, address payable[] memory _recipients)
        external
        payable
        nonReentrant
        onlyOwner
    {
        require(_amount.length == _recipients.length, 'Length not Equal');
        for (uint256 i = 0; i < _recipients.length; i++) {
            _recipients[i].transfer(_amount[i]);
            emit AirdropBNB(address(this), _recipients[i], _amount[i]);
        }
    }

    function withdrawBnb(address payable _toAddress, uint256 _amount) external nonReentrant onlyOwner {
        _toAddress.transfer(_amount);
        emit WithdrawBNB(address(this), _toAddress, _amount);
    }

    function depositBnb() external payable {
        emit DepositBNB(msg.sender, address(this), msg.value);
    }

    /* ERC1155 Recieve Functions */

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        operator;
        from;
        id;
        value;
        data;
        return (bytes4(keccak256('onERC1155Received(address,address,uint256,uint256,bytes)')));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        operator;
        from;
        ids;
        values;
        data;
        //Not allowed
        // return "";
        revert();
    }
}