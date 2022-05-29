// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './Ownable.sol';
import './IERC1155_EXT.sol';
import './SafeMath.sol';
import './SafeERC20.sol';
import './Math.sol';
import './ERC1155Receiver.sol';
import './ReentrancyGuard.sol';
import './AccessControl.sol';

contract Metacurse is AccessControl, Ownable, ERC1155Receiver, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    IERC1155_EXT public nft;
    IERC20 public token;

    struct UserNft{
        uint256[] nftDepositedId;
        uint256[] nftDeposited;
        uint256[] nftWithdrawnId;
        uint256[] nftWithdrawn;
        uint256[] nftDepositTime;
        uint256[] nftWithdrawTime;
    }

    struct UserToken{
        uint256[] tokenDeposited;
        uint256[] tokenWithdrawn;
        uint256[] tokenDepositTime;
        uint256[] tokenWithdrawTime;
    }

    mapping(address => UserNft) nftDetails;
    mapping(address => UserToken)  tokenDetails;


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
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Receiver, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /* NFT Functionality */

    function depositNft(uint256 _tokenID, uint256 _quantity) external {
        nft.safeTransferFrom(msg.sender, address(this), _tokenID, _quantity, '0x');
        
        nftDetails[msg.sender].nftDepositedId.push(_tokenID);
        nftDetails[msg.sender].nftDeposited.push(_quantity);
        nftDetails[msg.sender].nftDepositTime.push(block.timestamp);
        
        emit DepositNFT(msg.sender, address(this), _tokenID, _quantity);
    }

    function depositMultiNft(uint256[] memory _tokenId, uint256[] memory _quantity) external {
        depositMultiNFT(_tokenId, _quantity);
    }

    function depositMultiNFT(uint256[] memory _tokenId, uint256[] memory _quantity) internal {
        require(_tokenId.length == _quantity.length, 'Length not Equal');

        for (uint256 i = 0; i < _quantity.length; i++) {
            nft.safeTransferFrom(msg.sender, address(this), _tokenId[i], _quantity[i], '0x');

            nftDetails[msg.sender].nftDepositedId.push(_tokenId[i]);
            nftDetails[msg.sender].nftDeposited.push(_quantity[i]);
            nftDetails[msg.sender].nftDepositTime.push(block.timestamp);

            emit DepositNFT(msg.sender, address(this), _tokenId[i], _quantity[i]);
        }
    }

    function withdrawNft(
        uint256 _tokenID,
        address _to,
        uint256 _quantity
    ) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller does not have Access");
        nft.safeTransferFrom(address(this), _to, _tokenID, _quantity, '0x');

        nftDetails[_to].nftWithdrawnId.push(_tokenID);
        nftDetails[_to].nftWithdrawn.push(_quantity);
        nftDetails[_to].nftWithdrawTime.push(block.timestamp);
        
        emit WithdrawNFT(address(this), _to, _tokenID, _quantity);
    }


    function NFTAirdrop(
        uint256[] memory _tokenId,
        address[] memory _to,
        uint256[] memory _quantity
    ) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller does not have Access");
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

            nftDetails[_to[i]].nftWithdrawnId.push(_tokenId[i]);
            nftDetails[_to[i]].nftWithdrawn.push(_quantity[i]);
            nftDetails[_to[i]].nftWithdrawTime.push(block.timestamp);

            emit AirdropNFT(address(this), _to[i], _tokenId[i], _quantity[i]);
        }
    }

    function displayUserNftDeposit(address _userAdd, uint cursor, uint howMany) public view returns(uint256[] memory nftId, uint256[] memory nftDeposit, uint256[] memory nftDepositTime, uint newCursor){
        uint length = howMany;
        if (length > nftDetails[_userAdd].nftDepositedId.length - cursor) {
            length = nftDetails[_userAdd].nftDepositedId.length - cursor;
        }

        uint256[] memory depositId = new uint[] (length);
        uint256[] memory depositQuantity = new uint[] (length);
        uint256[] memory depositTime = new uint[] (length);
        for (uint i = 0; i < length; i++) {
            depositId[i] = nftDetails[_userAdd].nftDepositedId[cursor + i];
            depositQuantity[i] = nftDetails[_userAdd].nftDeposited[cursor + i];
            depositTime[i] = nftDetails[_userAdd].nftDepositTime[cursor + i];
        }

        return (depositId,depositQuantity,depositTime, cursor + length);
    }

    function displayUserNftWithdraw(address _userAdd, uint cursor, uint howMany) public view returns(uint256[] memory nftId, uint256[] memory nftWithdraw, uint256[] memory nftWithdrawTime, uint newCursor){
        uint length = howMany;
        if (length > nftDetails[_userAdd].nftWithdrawnId.length - cursor) {
            length = nftDetails[_userAdd].nftWithdrawnId.length - cursor;
        }

        uint256[] memory withdrawId = new uint[] (length);
        uint256[] memory withdrawQuantity = new uint[] (length);
        uint256[] memory withdrawTime = new uint[] (length);
        for (uint i = 0; i < length; i++) {
            withdrawId[i] = nftDetails[_userAdd].nftWithdrawnId[cursor + i];
            withdrawQuantity[i] = nftDetails[_userAdd].nftWithdrawn[cursor + i];
            withdrawTime[i] = nftDetails[_userAdd].nftWithdrawTime[cursor + i];
        }

        return (withdrawId,withdrawQuantity,withdrawTime, cursor + length);
    }

    

    /* Token Functionality */

    function depositToken(uint256 _amount) external nonReentrant {
        require(_amount <= token.balanceOf(msg.sender), 'Token Balance of user is less');
        require(token.allowance(msg.sender, address(this)) >= _amount, 'BEP20: Token Not Approved for Sale');
        token.transferFrom(msg.sender, address(this), _amount);

        tokenDetails[msg.sender].tokenDeposited.push(_amount);
        tokenDetails[msg.sender].tokenDepositTime.push(block.timestamp);

        emit DepositToken(msg.sender, address(this), _amount);
    }

    function withdrawToken(address _toAddress, uint256 _amount) external nonReentrant {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller does not have Access");
        token.transfer(_toAddress, _amount);

        tokenDetails[_toAddress].tokenWithdrawn.push(_amount);
        tokenDetails[_toAddress].tokenWithdrawTime.push(block.timestamp);

        emit WithdrawToken(address(this), _toAddress, _amount);
    }

    function withdrawMultiTokens(address[] memory _recipients, uint256[] memory _amount)
        external
        nonReentrant
        returns (bool)
    {   
        uint256 total = 0;
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller does not have Access");
        require(_recipients.length == _amount.length);
        for (uint256 j = 0; j < _amount.length; j++) {
            total = total.add(_amount[j]);
        }
        require(token.balanceOf(address(this)) >= total, 'Token Balance of contract is less than the total Airdrop');

        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0));
            require(token.transfer(_recipients[i], _amount[i]));
            
            tokenDetails[_recipients[i]].tokenWithdrawn.push(_amount[i]);
            tokenDetails[_recipients[i]].tokenWithdrawTime.push(block.timestamp);

            emit AirdropToken(address(this), _recipients[i], _amount[i]);
        }
        return true;
    }

    function displayUserTokenDeposit(address _userAdd, uint cursor, uint howMany) public view returns(uint256[] memory tokenDeposit, uint256[] memory tokenDepositedTime, uint newCursor){
        uint length = howMany;
        if (length > tokenDetails[_userAdd].tokenDeposited.length - cursor) {
            length = tokenDetails[_userAdd].tokenDeposited.length - cursor;
        }

        uint256[] memory tokenDeposited = new uint[] (length);
        uint256[] memory tokenDepositTime = new uint[] (length);
        for (uint i = 0; i < length; i++) {
            tokenDeposited[i] = tokenDetails[_userAdd].tokenDeposited[cursor + i];
            tokenDepositTime[i] = tokenDetails[_userAdd].tokenDepositTime[cursor + i];
        }

        return (tokenDeposited,tokenDepositTime, cursor + length);
    }

    function displayUserTokenWithdraw(address _userAdd, uint cursor, uint howMany) public view returns(uint256[] memory tokenWithdraw, uint256[] memory tokenWithdrawTime, uint newCursor){
        uint length = howMany;
        if (length > tokenDetails[_userAdd].tokenWithdrawn.length - cursor) {
            length = tokenDetails[_userAdd].tokenWithdrawn.length - cursor;
        }

        uint256[] memory tokenWithdrawed = new uint[] (length);
        uint256[] memory tokenWithdrawedTime = new uint[] (length);
        for (uint i = 0; i < length; i++) {
            tokenWithdrawed[i] = tokenDetails[_userAdd].tokenWithdrawn[cursor + i];
            tokenWithdrawedTime[i] = tokenDetails[_userAdd].tokenWithdrawTime[cursor + i];
        }

        return (tokenWithdrawed,tokenWithdrawedTime, cursor + length);
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