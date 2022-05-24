/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    address private _owner;

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: newOwner is zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Ceo {
    address public ceoAddress;

    constructor() {
        _transferCeo(msg.sender);
    }

    modifier onlyCeo() {
        require(ceoAddress == msg.sender, "CEO: caller is not the ceo");
        _;
    }

    function isCeo() public view returns (bool) {
        return msg.sender == ceoAddress;
    }

    function transferCeo(address _address) public onlyCeo {
        require(_address != address(0), "CEO: newAddress is the zero address");
        _transferCeo(_address);
    }

    function renounceCeo() public onlyCeo {
        _transferCeo(address(0));
    }

    function _transferCeo(address _address) internal {
        ceoAddress = _address;
    }
}

contract BusinessRole is Ceo, Ownable {
    address[] private _businesses;

    modifier onlyManager() {
        require(
            isOwner() || isBusiness() || isCeo(),
            "BusinessRole: caller is not business"
        );
        _;
    }

    function isBusiness() public view returns (bool) {
        for (uint256 i = 0; i < _businesses.length; i++) {
            if (_businesses[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function getBusinessAddresses() public view returns (address[] memory) {
        return _businesses;
    }

    function setBusinessAddress(address[] memory businessAddresses)
        public
        onlyOwner
    {
        _businesses = businessAddresses;
    }
}

interface IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function approvedFor(uint256 _tokenId) external view returns (address);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function transfer(address to, uint256 tokenId) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

    function safeMint(address user) external;

    function create(address to) external returns (uint256);

    function burn(uint256 tokenId) external;

    function _burnItem(address owner, uint256 tokenId) external;
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);
}

contract Withdrawable is BusinessRole {
    function _withdraw(uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Withdrawable: Insufficent balance to withdraw (coin)"
        );
        if (amount > 0) {
            payable(ceoAddress).transfer(amount);
        }
    }

    function _withdrawToken(IERC20 erc20, uint256 amount) internal {
        require(
            erc20.balanceOf(address(this)) >= amount,
            "Withdrawable: Insufficent balance to withdraw (token)"
        );

        if (amount > 0) {
            erc20.transfer(ceoAddress, amount);
        }
    }

    function withdraw(
        uint256 amount,
        address[] memory erc20s,
        uint256[] memory amountErc20s
    ) public onlyOwner {
        _withdraw(amount);
        for (uint256 i = 0; i < erc20s.length; i++) {
            _withdrawToken(IERC20(erc20s[i]), amountErc20s[i]);
        }
    }
}

contract PaymentProvider is Ownable {
    event SetTokensPayment(
        address user,
        address[] tokens,
        uint256[][] weiPrices
    );
    event SetNFTsPayment(address user, address[] nfts);
    event UnsetTokensPayment(address user, address[] tokens);
    event UnsetNFTsPayment(address user, address[] nfts);

    struct token {
        bool existed;
        uint256[] weiPrices;
        uint256 index;
    }
    struct nft {
        bool existed;
        uint256 index;
    }

    mapping(address => token) private tokensMap;
    mapping(address => nft) private nftsMap;

    address[] private tokensList;
    address[] private nftsList;

    modifier onlyValidToken(address _token) {
        require(
            tokensMap[_token].existed,
            "DrawGacha: Token payment is not valid"
        );
        _;
    }

    modifier onlyValidNft(address _nft) {
        require(nftsMap[_nft].existed, "DrawGacha: Nft payment is not valid");
        _;
    }

    function getTokenList() public view returns (address[] memory) {
        return tokensList;
    }

    function getToken(address _token)
        public
        view
        returns (bool, uint256[] memory)
    {
        return (tokensMap[_token].existed, tokensMap[_token].weiPrices);
    }

    function getNftList() public view returns (address[] memory) {
        return nftsList;
    }

    function setTokens(address[] memory _tokens, uint256[][] memory _weiPrices)
        public
        onlyOwner
    {
        require(
            _tokens.length == _weiPrices.length,
            "DrawGacha: Token and weiPrice length miss match"
        );
        for (uint256 i = 0; i < _tokens.length; i++) {
            tokensMap[_tokens[i]].weiPrices = _weiPrices[i];
            if (!tokensMap[_tokens[i]].existed) {
                tokensList.push(_tokens[i]);
                tokensMap[_tokens[i]].existed = true;
                tokensMap[_tokens[i]].index = tokensList.length - 1;
            }
        }
        emit SetTokensPayment(msg.sender, _tokens, _weiPrices);
    }

    function unsetTokens(address[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (tokensMap[_tokens[i]].existed) {
                uint256 indexRemove = tokensMap[_tokens[i]].index;
                tokensList[indexRemove] = tokensList[tokensList.length - 1];
                tokensMap[tokensList[indexRemove]].index = indexRemove;
                tokensList.pop();
                delete tokensMap[_tokens[i]];
            }
        }
        emit UnsetTokensPayment(msg.sender, _tokens);
    }

    function setNfts(address[] memory _nfts) public onlyOwner {
        for (uint256 i = 0; i < _nfts.length; i++) {
            if (!nftsMap[_nfts[i]].existed) {
                nftsList.push(_nfts[i]);
                nftsMap[_nfts[i]].existed = true;
                nftsMap[_nfts[i]].index = nftsList.length - 1;
            }
        }
        emit SetNFTsPayment(msg.sender, _nfts);
    }

    function unsetNfts(address[] memory _nfts) public onlyOwner {
        for (uint256 i = 0; i < _nfts.length; i++) {
            if (nftsMap[_nfts[i]].existed) {
                uint256 indexRemove = nftsMap[_nfts[i]].index;
                nftsList[indexRemove] = nftsList[nftsList.length - 1];
                nftsMap[nftsList[indexRemove]].index = indexRemove;
                nftsList.pop();
                delete nftsMap[_nfts[i]];
            }
        }
        emit UnsetNFTsPayment(msg.sender, _nfts);
    }
}

contract DrawGacha is PaymentProvider, Withdrawable {
    event BuyTicket(
        address _from,
        uint256 ticket,
        address erc20,
        uint256 amount
    );
    event BuyTicketNFT(
        address _from,
        uint256 ticket,
        address erc721,
        uint256 tokenId
    );
    event RewardMainCoin(uint256 ticket, address _to, uint256 amount);
    event RewardERC20(
        uint256 ticket,
        address _to,
        address erc20,
        uint256 amount
    );
    event RewardERC721(
        uint256 ticket,
        address _to,
        address erc721,
        uint256 tokenId
    );

    struct ticket {
        address user;
        bool isUsed;
    }

    mapping(uint256 => ticket) public tickets;

    function validTicket(uint256 _ticket) public view returns (bool) {
        return (tickets[_ticket].user != address(0) &&
            !tickets[_ticket].isUsed);
    }

    function validBuyTicket(uint256 _ticket) public view returns (bool) {
        return (tickets[_ticket].user == address(0));
    }

    modifier onlyValidTicket(uint256 _ticket) {
        require(validTicket(_ticket), "DrawGacha: ticket is not valid");
        _;
    }

    modifier onlyValidBuyTicket(uint256 _ticket) {
        require(
            validBuyTicket(_ticket),
            "DrawGacha: ticket has been purchased"
        );
        _;
    }

    function getTicket(uint256 _ticket) public view returns (ticket memory) {
        return tickets[_ticket];
    }

    function buyTicketByToken(
        uint256 _ticket,
        address erc20,
        uint256 typeticket
    ) public onlyValidBuyTicket(_ticket) onlyValidToken(erc20) {
        (, uint256[] memory weiPrices) = getToken(erc20);
        require(
            IERC20(erc20).transferFrom(
                msg.sender,
                address(this),
                weiPrices[typeticket]
            ),
            "DrawGacha: transfer fail"
        );
        tickets[_ticket] = ticket(msg.sender, false);
        emit BuyTicket(msg.sender, _ticket, erc20, weiPrices[typeticket]);
    }

    function buyTicketByNFT(
        uint256 _ticket,
        address erc721,
        uint256 tokenId
    ) public onlyValidBuyTicket(_ticket) onlyValidNft(erc721) {
        IERC721(erc721).transferFrom(msg.sender, address(this), tokenId);
        IERC721(erc721).burn(tokenId);
        tickets[_ticket] = ticket(msg.sender, false);

        emit BuyTicketNFT(msg.sender, _ticket, erc721, tokenId);
    }

    function rewardMainCoin(
        uint256 _ticket,
        address _user,
        uint256 _amount
    ) public payable onlyManager onlyValidTicket(_ticket) {
        payable(_user).transfer(_amount);
        tickets[_ticket].isUsed = true;

        emit RewardMainCoin(_ticket, _user, _amount);
    }

    function rewardERC20(
        uint256 _ticket,
        address _user,
        address _erc20,
        uint256 _amount
    ) public onlyManager onlyValidTicket(_ticket) {
        IERC20(_erc20).transferFrom(msg.sender, _user, _amount);
        tickets[_ticket].isUsed = true;
        emit RewardERC20(_ticket, _user, _erc20, _amount);
    }

    function rewardERC721(
        uint256 _ticket,
        address _user,
        address _erc721
    ) public onlyManager onlyValidTicket(_ticket) {
        uint256 tokenId = IERC721(_erc721).create(_user);
        tickets[_ticket].isUsed = true;
        emit RewardERC721(_ticket, _user, _erc721, tokenId);
    }
}