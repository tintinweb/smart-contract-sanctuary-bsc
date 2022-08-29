// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Strings.sol";
import "./SafeTransferLib.sol";
import "./ReentrancyGuard.sol";

interface IDao {
    function relationships(address recommend) external returns (address);

    function setRelationship(
        address referrer,
        address recommend,
        uint256 amount
    ) external;
}

contract NPNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    mapping(address => bool) public mintAccess;

    uint256 seventhNumber = 3200;

    uint256 seventhPrice = 640 ether;

    uint256 eighthNumber = 3600;

    uint256 eighthPrice = 1280 ether;

    uint256 bestSix = 1600;

    address public dao;

    uint256 public max_supply = 10000;

    uint256 public curentMint;

    uint256 private currentCommonMint;

    string private image_uri = "https://";

    string public suffix = ".png";

    address public paycoin = 0x15BC362e500c82e981640A618E8FB61F614921a0;

    uint256 public price = 320 ether;

    uint256 public directProportion = 100;

    uint256 public secondaryProportion = 50;

    bool public publicMintStatus;

    address public vault;

    struct Category {
        uint64 start;
        uint64 end;
        uint64 current;
        uint32 multiplier;
        uint32 level;
    }

    Category[7] public categorys;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        categorys[0] = Category({
        start: uint64(1),
        end: uint64(3000),
        current: uint64(0),
        multiplier: uint32(10),
        level: uint32(1)
        });

        categorys[1] = Category({
        start: uint64(3001),
        end: uint64(5000),
        current: uint64(3000),
        multiplier: uint32(11),
        level: uint32(2)
        });

        categorys[2] = Category({
        start: uint64(5001),
        end: uint64(6500),
        current: uint64(5000),
        multiplier: uint32(13),
        level: uint32(3)
        });

        categorys[3] = Category({
        start: uint64(6501),
        end: uint64(7700),
        current: uint64(6500),
        multiplier: uint32(15),
        level: uint32(4)
        });

        categorys[4] = Category({
        start: uint64(7701),
        end: uint64(8700),
        current: uint64(7700),
        multiplier: uint32(18),
        level: uint32(5)
        });

        categorys[5] = Category({
        start: uint64(8701),
        end: uint64(9700),
        current: uint64(8700),
        multiplier: uint32(20),
        level: uint32(6)
        });

        categorys[6] = Category({
        start: uint64(9701),
        end: uint64(10000),
        current: uint64(9700),
        multiplier: uint32(30),
        level: uint32(7)
        });
    }

    function setAccesses(address mintor, bool access) public onlyOwner {
        mintAccess[mintor] = access;
    }

    function setImageUri(string memory _uri) public onlyOwner {
        image_uri = _uri;
    }

    function setPublicMint(address _paycoin, uint256 _price) public onlyOwner {
        paycoin = _paycoin;

        price = _price;
    }

    function setSuffix(string memory _suffix) public onlyOwner{
        suffix = _suffix;
    }

    function setVault(address _vault) public onlyOwner {
        require(_vault != address(0), "zero address");

        vault = _vault;
    }

    function setPrice(
        uint256 _rotate,
        uint256 _num,
        uint256 _price
    ) public onlyOwner {
        if (_rotate == 7) {
            seventhNumber = _num;

            seventhPrice = _price;
        } else if (_rotate == 8) {
            eighthNumber = _num;

            eighthPrice = _price;
        }
    }

    function setDao(
        address _dao,
        uint256 _directProportion,
        uint256 _secondaryProportion
    ) public onlyOwner {
        dao = _dao;

        directProportion = _directProportion;

        secondaryProportion = _secondaryProportion;
    }

    function updatePulicMintStatus(bool _publicMintStatus) public onlyOwner {
        publicMintStatus = _publicMintStatus;
    }

    function mint(
        address to,
        uint256 num,
        uint256 mint_type,
        address refferr
    ) public nonReentrant returns (bool) {
        require(totalSupply() + num <= max_supply && num > 0, " mint is over");

        if (mint_type == 1) {
            // pre mint common
            return preCommon(to, num);
        } else if (mint_type == 2) {
            // pre mint sr
            return preSR(to, num);
        } else if (mint_type == 3) {
            // pre mint ssr
            return preSSR(to, num);
        } else {
            //public mint
            return publicMint(to, num, refferr);
        }
    }

    function preCommon(address to, uint256 num) internal returns (bool) {
        require(mintAccess[msg.sender], "mint :: deny");

        require(currentCommonMint + num <= 8700, "common is over");

        uint256 tokenId;

        for (uint256 i = 0; i < num; i++) {
            tokenId = _pickTokenId(random(to, 8700 - currentCommonMint));

            _mint(to, tokenId);

            currentCommonMint++;

            curentMint++;
        }

        return true;
    }

    function preSR(address to, uint256 num) internal returns (bool) {
        require(mintAccess[msg.sender], "mint :: deny");

        Category storage category = categorys[5];

        require(category.current + num <= category.end, "sr not enough");
        uint256 tokenId;

        for (uint256 i = 0; i < num; i++) {
            category.current++;

            tokenId = category.current;

            _mint(to, tokenId);

            curentMint++;
        }

        return true;
    }

    function preSSR(address to, uint256 num) internal returns (bool) {
        require(mintAccess[msg.sender], "mint :: deny");

        Category storage category = categorys[6];

        require(category.current + num <= category.end, "ssr not enough");
        uint256 tokenId;

        for (uint256 i = 0; i < num; i++) {
            category.current++;

            tokenId = category.current;

            _mint(to, tokenId);

            curentMint++;
        }
        return true;
    }

    function publicMint(
        address to,
        uint256 num,
        address refferr
    ) internal returns (bool) {
        require(publicMintStatus, "public mint not start");
        require(num > 0, "can not be zero");
        require(curentMint + num <= max_supply, "out of range");
        uint256 tempNumber;
        if (curentMint + 1 > max_supply - eighthNumber) {
            tempNumber = max_supply;
            price = eighthPrice;
        } else if (curentMint + 1 > max_supply - eighthNumber - seventhNumber) {
            tempNumber = max_supply - eighthNumber;
            price = seventhPrice;
        } else {
            tempNumber = max_supply - eighthNumber - seventhNumber;
        }

        require(
            tempNumber - curentMint - num >= 0,
            "Exceeds the current number of rounds"
        );

        require(msg.sender == tx.origin, "caller not contract");

        uint256 tokenId;

        if (paycoin != address(0) && price > 0) {
            uint256 amount = price * num;

            uint256 left = amount;

            if (refferr != address(0)) {
                IDao(dao).setRelationship(refferr, msg.sender, 0);
            }

            address refferrs = IDao(dao).relationships(msg.sender);

            if (refferrs != address(0)) {
                SafeTransferLib.safeTransferFrom(
                    paycoin,
                    msg.sender,
                    refferrs,
                    (amount * directProportion) / 1000
                );

                left = left - amount * directProportion / 1000;
            }

            if (IDao(dao).relationships(refferrs) != address(0)) {
                SafeTransferLib.safeTransferFrom(
                    paycoin,
                    msg.sender,
                    IDao(dao).relationships(refferrs),
                    (amount * secondaryProportion) / 1000
                );

                left = left - amount * secondaryProportion / 1000;
            }

            SafeTransferLib.safeTransferFrom(paycoin, msg.sender, vault, left);
        }

        for (uint256 i = 0; i < num; i++) {
            tokenId = _pickTokenId(random(to, max_supply - curentMint));

            _mint(to, tokenId);

            if (tokenId <= 8700) {
                currentCommonMint++;
            }

            curentMint++;
        }
        return true;
    }

    function randomIdoMint(address to) public returns (bool) {
        require(mintAccess[msg.sender], "mint :: deny");
        require(curentMint < max_supply, "out of range");
        uint256 tokenId = _pickTokenId(random(to, max_supply - curentMint));

        _mint(to, tokenId);

        if (tokenId <= 8700) {
            currentCommonMint++;
        }

        curentMint++;

        return true;
    }

    function getCurrentInfo()
    public
    view
    returns (
        uint256 _mintNum,
        uint256 _currentPrice,
        uint256 _currentNumber
    )
    {
        if (curentMint + 1 > max_supply - eighthNumber) {
            _mintNum = curentMint - (max_supply - eighthNumber);
            _currentNumber = eighthNumber;
            _currentPrice = eighthPrice;
        } else if (curentMint + 1 > max_supply - eighthNumber - seventhNumber) {
            _mintNum = curentMint - (max_supply - eighthNumber - seventhNumber);
            _currentNumber = seventhNumber;
            _currentPrice = seventhPrice;
        } else {
            if (curentMint >= bestSix) {
                _mintNum = curentMint - bestSix;
            } else {
                _mintNum = curentMint;
            }

            _currentNumber = 1600;
            _currentPrice = price;
        }
    }

    function getLevelAndMultiplier(uint256 tokenId)
    public
    view
    returns (uint256 level, uint256 multiplier)
    {
        for (uint256 i = 0; i < 7; i++) {
            Category storage category = categorys[i];

            if (category.start <= tokenId && tokenId <= category.end) {
                level = uint256(category.level);
                multiplier = uint256(category.multiplier);

                break;
            }
        }
    }

    function tokenURI(uint256 id)
    public
    view
    virtual
    override
    returns (string memory)
    {
        string memory idStr = Strings.toString(id);

        string memory _name = string(abi.encodePacked("# ", idStr));

        (uint256 _level, uint256 _multiplier) = getLevelAndMultiplier(id);

        string memory level = Strings.toString(_level);

        string memory multiplier = Strings.toString(_multiplier);

        string memory _image = string(abi.encodePacked(image_uri, idStr,suffix));

        if (id < 8701) {
            _name = string(abi.encodePacked("Burj Al Arab ", _name));
        } else if (id < 9701) {
            _name = string(abi.encodePacked("Burj Khalifa Tower ", _name));
        } else {
            _name = string(abi.encodePacked("Candlelight ", _name));
        }

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "',
                _name,
                '","level": "',
                level,
                '","image": "',
                _image,
                '","multiplier": "',
                multiplier,
                '","TokenId": "',
                idStr,
                '"}'
            )
        );
        // return string(abi.encodePacked(
        //         "data:application/json;base64,",
        //         Base64.encode(bytes(metadata))
        //         ));
        return metadata;
    }

    function _pickTokenId(uint256 seed) internal returns (uint256 tokenId) {
        uint256 left;

        for (uint256 i = 0; i < 7; i++) {
            Category storage category = categorys[i];

            left = left + uint256(category.end - category.current);

            if (seed < left) {
                category.current++;

                tokenId = category.current;

                break;
            }
        }
    }

    function random(address minter, uint256 throld)
    internal
    view
    returns (uint256)
    {
        return
        uint256(keccak256(abi.encodePacked(minter, block.timestamp))) % throld;
    }

    function withdraw(address _token, uint256 amount) public onlyOwner {
        if (_token == address(0)) {
            SafeTransferLib.safeTransferETH(msg.sender, amount);
        } else {
            SafeTransferLib.safeTransfer(_token, msg.sender, amount);
        }
    }
}