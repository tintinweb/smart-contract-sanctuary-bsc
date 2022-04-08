/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface beans {
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}

interface egg {
    function goldenEggTransferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


interface land {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function allLandRun(uint256) external view returns (
        uint256 tokenId,
        address mintedBy,
        address currentOwner,
        uint256 previousPrice,
        uint256 price,
        uint256 numberOfTransfers,
        bool forSale,
        uint forSalLog,
        uint quality
    );
}


contract SeedRunMain {
    beans be = beans(0x27f8125c2cc73667A88EB941586A78863e3B2514);
    egg eg = egg(0x4451b3839205570f878a9c6626B4853Dc9bB02aD);
    land la = land(0xCB594F15170E4d342EA08dE383718E6Aa1E1105B);

    //seed
    uint8 public constant decimals = 18;

    uint public seedTotalSupply = 0;

    mapping(address => mapping (address => uint256)) private _seedAllowance;

    mapping(address => uint) public seedBalanceOf; 

     struct Research {
        uint256 timeInDays;
        uint256 initBlock; //Block when research started
        bool discovered;
        uint256 tokenId;
        address owner;
    }   

    mapping(uint256 => Research) public landResearchs;

    mapping(uint256 => bool) public increase;

    event SeedTransfer(address indexed from, address indexed to, uint amount);
    event SeedApproval(address indexed from, address indexed to, uint amount);

    //TODO
    function seedClaim(address ads, uint seed) external {
        _seedMint(ads, seed);
        //1000000000000000000
    }


    /**
     * @dev See {approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function seedApprove(address spender, uint256 amount) public virtual returns (bool) {
        _seedApprove(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _seedApprove(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _seedAllowance[owner][spender] = amount;
        emit SeedApproval(owner, spender, amount);
    }


    function _seedMint(address dst, uint amount) internal {
        seedTotalSupply += amount;
        seedBalanceOf[dst] += amount;
        emit SeedTransfer(dst, dst, amount);
    }

    function seedTransfer(address to, uint amount) external returns (bool) {
        _seedTransferTokens(_msgSender(), to, amount);
        return true;
    }

    /**
     * @dev See {transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function seedTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _seedTransferTokens(sender, recipient, amount);

        uint256 currentAllowance = _seedAllowance[sender][_msgSender()];
        require(currentAllowance >= amount, "transfer amount exceeds allowance");
        unchecked {
            _seedApprove(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function _seedTransferTokens(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        seedBalanceOf[sender] -= amount;
        seedBalanceOf[recipient] += amount;
        emit SeedTransfer(sender, recipient, amount);
    }

    function exchange(uint256 numberOfToken) external {
        require(tx.origin == _msgSender(), "Only EOA");
        eg.goldenEggTransferFrom(_msgSender(), address(this), numberOfToken * 1 ether);
        _seedMint(_msgSender(), numberOfToken * 1 ether);
    }

    function  sowing(uint256 _landTokenId) external {
        require(_msgSender() == la.ownerOf(_landTokenId), "Land Only owner");
        (,,,,,,,,uint quality) = la.allLandRun(_landTokenId);//land Common、Rare、Epic
        uint256 timeInDays;
        //If empty or already discovered
        require(landResearchs[_landTokenId].timeInDays == 0 || landResearchs[_landTokenId].discovered == true, "not empty or not discovered yet");
        if (quality == 1) {
            timeInDays =  1 days;//24h
        } else if (quality == 2) {
            timeInDays =  20 hours;//20h 
        } else if (quality == 3) {
            timeInDays =  16 hours;//16h 
        }
        //timeInDays;  block.timestamp  false _landTokenId _msgSender()
        landResearchs[_landTokenId] = Research(timeInDays, block.timestamp, false, _landTokenId, _msgSender());
        //deduct
        _seedTransferTokens(_msgSender(), address(this), 1 ether);
    }

    function upgrade(uint256 _landTokenId) external {
        require(_msgSender() == la.ownerOf(_landTokenId), "Land Only owner");
        require(!increase[_landTokenId]);
        increase[_landTokenId] = true;
        eg.goldenEggTransferFrom(_msgSender(), address(this), 1 ether);
    }

    function income(uint256 _landTokenId) external {
        require(_msgSender() == la.ownerOf(_landTokenId), "Land Only owner");
        //already discovered or timeInDays>0
        require(!landResearchs[_landTokenId].discovered && landResearchs[_landTokenId].timeInDays > 0, "already discovered or not initialized");
        //(initBlock + timeInDays) < block.timestamp
        require(landResearchs[_landTokenId].initBlock + landResearchs[_landTokenId].timeInDays < block.timestamp, "not finish yet");
        //Reward
        landResearchs[_landTokenId].discovered = true;
        //TODO  address为持币人
        if (!increase[_landTokenId]) {
            be.transferFrom(address(0xF0C509199d6C8D75a241921840d1a959b349BAb0), _msgSender(), 50000 ether);
        } else {
            increase[_landTokenId] = false;
            be.transferFrom(address(0xF0C509199d6C8D75a241921840d1a959b349BAb0), _msgSender(), 70000 ether);
        }
    }


    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}