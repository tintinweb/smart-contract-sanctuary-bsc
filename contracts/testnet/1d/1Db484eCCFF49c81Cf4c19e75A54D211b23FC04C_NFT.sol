// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./ERC1155.sol";
import "./Strings.sol";

contract NFT is ERC1155, Ownable {
    using Strings for uint256;

    string name;
    string symbol;

    string baseURI;
    string notRevealedUri;
    string public baseExtension = ".json";
    bool public paused;

    uint256 public cost = 0.05 ether;
    uint256 public totalPaid;

    uint256 private tokenIds;

    mapping(address => uint256[]) adrToIds;

    mapping(uint256 => Item) private items;

    mapping(address => bool) blacklist;
    mapping(address => wl) whitelist;

    uint256 public usersWhitelisted;
    uint256 public userBlacklisted;

    mapping(uint256 => lv) private updateLV;

    struct lv {
        string newLV;
        bool isUpdated;
    }

    struct wl {
        uint256 amount;
        uint256 transferFee;
        uint256 cost;
    }

    mapping(address => uint256) public amountsNFT;
    mapping(address => uint256) public amountsNFTMinted;
    /*mapping(address => uint256[]) public idOfUser;*/

    mapping(uint256 => Admin) idToAdmin;
    mapping(address => uint256) adrToId;
    mapping(address => bool) isAdmin;
    uint256 public adminAmount;
    address[] private admins;

    struct Admin {
        uint256 id;
        address user;
        bool isAdmin;
    }

    bool public revealed;

    uint256 public nftAmountPerUser;
    uint256 public transferFee = 0.001 ether;

    uint256 public maxAmount = 13;
    uint256 public currentAmount;

    struct Item {
        uint256 id;
        address creator;
        uint256 quantity;
        address holder;
    }

    constructor(
        uint256 cost_,
        uint256 transferFee_,
        string memory uri_,
        string memory notRevealedUri_,
        uint256 nftAmountPerUser_,
        //bool revealDefault_,
        //uint256 maxAmount_,
        string memory name_,
        string memory symbol_
    ) ERC1155(uri_) {
        cost = cost_;
        transferFee = transferFee_;
        notRevealedUri = notRevealedUri_;
        baseURI = uri_;
        paused = true;
        nftAmountPerUser = nftAmountPerUser_;
        //revealed = revealDefault_;
        //maxAmount = maxAmount_;
        name = name_;
        symbol = symbol_;
    }

    function mint(address to, uint256 amount) external payable {
        require(!paused, "mint is paused");

        require(blacklist[msg.sender] == false, "you are in blacklist");
        require(currentAmount + amount <= maxAmount);
        if (whitelist[msg.sender].amount > 0) {
            require(
                msg.value >= whitelist[msg.sender].cost * amount,
                "Insufficient funds1"
            );
            require(
                amountsNFTMinted[msg.sender] + amount <= whitelist[to].amount,
                "nft collection amount is exceeded"
            );
            totalPaid += amount * whitelist[msg.sender].cost;
        } else {
            require(msg.value >= cost * amount, "Insufficient funds2");
            require(
                amountsNFTMinted[msg.sender] + amount <= nftAmountPerUser,
                "nft collection amount is exceeded"
            );
            totalPaid += amount * cost;
        }

        for (uint256 i; i < amount; i++) {
            _mint(to, tokenIds, 1, "");
            currentAmount++;
            if (!isInArray(adrToIds[to], tokenIds)) {
                adrToIds[to].push(tokenIds);
            }

            items[tokenIds] = Item(tokenIds, msg.sender, 1, to);

            amountsNFT[to]++;
            amountsNFTMinted[msg.sender]++;
            //idOfUser[msg.sender].push(tokenIds);

            tokenIds++;
        }
    }

    function revealNFTs() external onlyOwner {
        revealed = !revealed;
    }

    function nameCollection() external view returns (string memory) {
        return name;
    }

    function symbolCollection() external view returns (string memory) {
        return symbol;
    }

    function setNameCollection(string memory name_) external onlyOwner {
        name = name_;
    }

    function changePauseStatus() external onlyOwner {
        paused = !paused;
    }

    function changeMaxAmount(uint256 newMaxAMount) external onlyOwner {
        require(newMaxAMount >= currentAmount);
        maxAmount = newMaxAMount;
    }

    function changeTransferFee(uint256 newTransferFee) external onlyOwner {
        transferFee = newTransferFee;
    }

    function changeNftAmountPerUser(uint256 newAmount) external onlyOwner {
        nftAmountPerUser = newAmount;
    }

    function checkUserIds() external view returns (uint256[] memory) {
        return adrToIds[msg.sender];
    }

    /*function checkItems() external view returns (Item memory){
        return(items[msg.sender]);
    }*/

    /*function totalSupply() external view returns (uint256) {
        return tokenIds;
    }*/

    function checkUserMintedAmount() external view returns (uint256) {
        return amountsNFTMinted[msg.sender];
    }

    function checkUserActualAmount() external view returns (uint256) {
        return amountsNFT[msg.sender];
    }

    function _ownerOf(uint256 tokenId) internal view returns (bool) {
        return balanceOf(msg.sender, tokenId) != 0;
    }

    function isInArray(uint256[] memory Ids, uint256 id)
        internal
        pure
        returns (bool)
    {
        for (uint256 i; i < Ids.length; i++) {
            if (Ids[i] == id) {
                return true;
            }
        }
        return false;
    }

    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(tokenId <= tokenIds);
        if (revealed == false) {
            return notRevealedUri;
        }

        // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
        if (updateLV[tokenId].isUpdated) {
            return updateLV[tokenId].newLV;
        }
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, tokenId.toString(), baseExtension)
                )
                : "";
    }

    function changeMeta(uint256 id, string memory newMeta) external {
        require(
            msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin
        );

        require(id < currentAmount, "Non existing nft id");
        updateLV[id].newLV = newMeta;
        updateLV[id].isUpdated = true;
    }

    function batchTransfer(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external payable {
        require(blacklist[msg.sender] == false, "User blacklisted");
        for (uint256 i; i < amounts.length; i++) {
            require(amounts[i] == 1, "amount has to be 1");
        }
        require(from == msg.sender, "not allowance");
        if (whitelist[msg.sender].amount > 0) {
            require(
                msg.value >= whitelist[msg.sender].transferFee * ids.length,
                "Insufficient funds1"
            );
            totalPaid += ids.length * whitelist[msg.sender].transferFee;
        } else {
            require(
                msg.value >= transferFee * ids.length,
                "Insufficient funds2"
            );
            totalPaid += ids.length * transferFee;
        }
        //require(msg.value >= transferFee, "Insufficient funds");
        _safeBatchTransferFrom(from, to, ids, amounts, "");
        //adrToIds[msg.sender]
        for (uint256 i; i < adrToIds[msg.sender].length; i++) {
            for (uint256 j; j < ids.length; j++) {
                if (adrToIds[msg.sender][i] == ids[j]) {
                    adrToIds[to].push(ids[j]);
                    remove(i);
                    items[ids[j]].holder = to;
                }
            }
        }
        amountsNFT[msg.sender] -= ids.length;
        amountsNFT[to] += ids.length;
    }

    function transfer(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external payable {
        require(blacklist[msg.sender] == false, "User blacklisted");
        require(from == msg.sender, "not allowance");
        require(amount == 1, "amount has to be 1");
        if (whitelist[msg.sender].amount > 0) {
            require(
                msg.value >= whitelist[msg.sender].transferFee,
                "Insufficient funds1"
            );
            totalPaid += whitelist[msg.sender].transferFee;
        } else {
            require(msg.value >= transferFee, "Insufficient funds2");
            totalPaid += transferFee;
        }
        //require(msg.value >= transferFee, "Insufficient funds");
        _safeTransferFrom(from, to, id, amount, "");
        items[id].holder = to;

        for (uint256 i; i < adrToIds[msg.sender].length; i++) {
            if (adrToIds[msg.sender][i] == id) {
                adrToIds[to].push(id);
                remove(i);
            }
        }
        amountsNFT[msg.sender]--;
        amountsNFT[to]++;
    }

    function remove(uint256 index) internal returns (uint256[] memory) {
        //if (index >= adrToIds[msg.sender].length) return ;

        for (uint256 i = index; i < adrToIds[msg.sender].length - 1; i++) {
            adrToIds[msg.sender][i] = adrToIds[msg.sender][i + 1];
        }
        delete adrToIds[msg.sender][adrToIds[msg.sender].length - 1];
        adrToIds[msg.sender].pop();
        return adrToIds[msg.sender];
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {}

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function addToWhitelist(
        address user_,
        uint256 amount_,
        uint256 transferFee_,
        uint256 cost_
    ) external {
        if (isAdmin[user_]) {
            require(
                msg.sender == owner(),
                "only owner can add admin to whitelist"
            );
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can add to whitelist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user_ != owner(), "Not possible to add owner");
            }
        }
        require(whitelist[user_].amount == 0, "Already in whitelist");
        require(blacklist[msg.sender] == false, "Admin blacklisted");

        usersWhitelisted++;

        whitelist[user_].amount = amount_;
        whitelist[user_].transferFee = transferFee_;
        whitelist[user_].cost = cost_;
    }

    function deleteFromWhitelist(address user) external {
        if (isAdmin[user]) {
            require(
                msg.sender == owner(),
                "only owner can delete admin from whitelist"
            );
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can delete from whitelist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user != owner(), "Not possible to add owner");
            }
        }
        require(blacklist[msg.sender] == false, "Admin blacklisted");

        require(whitelist[user].amount > 0, "User is not in whitelist");
        whitelist[user].amount = 0;
        whitelist[user].transferFee = 0;
        whitelist[user].cost = 0;
        usersWhitelisted--;
    }

    function addToBlacklist(address user) external {
        if (isAdmin[user]) {
            require(
                msg.sender == owner(),
                "only owner can add admin to blacklist"
            );
            idToAdmin[adrToId[user]].isAdmin = false;
            for (uint256 i; i < admins.length; i++) {
                if (admins[i] == idToAdmin[adrToId[user]].user) {
                    removeAdmin(i);
                    break;
                }
            }
            adminAmount--;
            isAdmin[user] = false;
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can add to blacklist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user != owner(), "Not possible to add owner");
            }
        }
        require(blacklist[msg.sender] == false, "Admin blacklisted");
        require(blacklist[user] == false, "User already blacklisted");
        blacklist[user] = true;
        userBlacklisted++;
    }

    function deleteFromBlacklist(address user) external {
        if (isAdmin[user]) {
            require(
                msg.sender == owner(),
                "only Owner can delete admin from blacklist"
            );
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can delete from blacklist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user != owner(), "Not possible to add owner");
            }
        }
        require(blacklist[user] == true, "Admin is not blacklisted");
        require(blacklist[msg.sender] == false, "Admin is not blacklisted");
        blacklist[user] = false;
        userBlacklisted--;
    }

    function addAdmin(address admin) external onlyOwner {
        require(blacklist[msg.sender] == false, "User blacklisted");
        require(isAdmin[admin] != true, "Already admin");
        adminAmount++;
        idToAdmin[adminAmount] = Admin(adminAmount, admin, true);
        adrToId[admin] = adminAmount;
        admins.push(admin);
        isAdmin[admin] = true;
    }

    function showAdmins() external view returns (address[] memory) {
        return (admins);
    }

    function deleteAdmin(address admin) external onlyOwner {
        //require(blacklist[admin] == false, "User blacklisted");
        require(
            idToAdmin[adrToId[admin]].isAdmin == true,
            "User is not in admin list"
        );
        idToAdmin[adrToId[admin]].isAdmin = false;
        for (uint256 i; i < admins.length; i++) {
            if (admins[i] == idToAdmin[adrToId[admin]].user) {
                removeAdmin(i);
                break;
            }
        }
        adminAmount--;
        isAdmin[admin] = false;
    }

    function removeAdmin(uint256 index) internal returns (address[] memory) {
        //if (index >= adrToIds[msg.sender].length) return ;

        for (uint256 i = index; i < admins.length - 1; i++) {
            admins[i] = admins[i + 1];
        }
        delete admins[admins.length - 1];
        admins.pop();
        return admins;
    }

    function showItems(uint256 number) external view returns (Item memory) {
        require(items[number].id <= tokenIds);
        return items[number];
    }

    function isUserInBlacklist(address user) external view returns (bool) {
        require(
            msg.sender == owner() ||
                msg.sender == user ||
                idToAdmin[adrToId[msg.sender]].isAdmin
        );

        return blacklist[user];
    }

    //function changeParametersWhitelist(address user, )

    function isUserInWhitelist(address user)
        external
        view
        returns (
            uint256 amountOf,
            uint256 feeForTransfer,
            uint256 costOfMint
        )
    {
        require(
            msg.sender == owner() ||
                msg.sender == user ||
                idToAdmin[adrToId[msg.sender]].isAdmin
        );

        if (whitelist[user].amount == 0) {
            require(whitelist[user].amount != 0, "User is not whilelisted");
            return (0, 0, 0);
        } else {
            return (
                whitelist[user].amount,
                whitelist[user].transferFee,
                whitelist[user].cost
            );
        }
    }

    function availableNFTs()
        external
        view
        returns (
            uint256 amount,
            uint256 feeForTransfer,
            uint256 costForMint
        )
    {
        if (whitelist[msg.sender].amount > 0) {
            return (
                whitelist[msg.sender].amount - amountsNFTMinted[msg.sender],
                whitelist[msg.sender].transferFee,
                whitelist[msg.sender].cost
            );
        } else {
            return (
                nftAmountPerUser - amountsNFTMinted[msg.sender],
                transferFee,
                cost
            );
        }
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}