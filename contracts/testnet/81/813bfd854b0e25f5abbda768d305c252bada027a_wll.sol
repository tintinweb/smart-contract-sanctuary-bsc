/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract wll is Ownable {
    //address coinContract = 0x978255b648d5d99F3639eb90e8B6083638ACBBfb;
    address coinContract = 0xEF4209c731C9cEBa90d920279e18f392CAE4B7BC;
    address[] wl = [0xF6b040F1C27eC1B94ED489DcFc631C721b72B41c,
                        0xa6aa5e28C5542761f392A49d5FE648B791d256a4,
                        0xd5091aca0c4B8103D3BD2fc911134B5509F15F16,
                        0x96A87d8554E0A82Cea00E687D9Fe8b1453EE787d,
                        0xfB3C1F11F689091b843E611dC7da417599EAA41F,
                        0x10F3eDC2cA226d1582D92581400Ea2A2B9a8A2A1,
                        0x3a37F8043FFa8202eb8E8CC62C725bBd10C314b0,
                        0x1ae79b19CA8Dc660033f3f66E8d8828EA1Be9b42,
                        0x60729B15e875DC48E358E4E2D400355C146344Ca,
                        0x807A7f3635f264fc758d36e35C8993401d122917,
                        0xb0aE45917639f3e0274312D8c96411b20A00B356,
                        0x2167e98452D14b93711Fe49e5196f27a9603C3cD,
                        0xf1F78711B4516097c256aF01582B134c3441b0bA,
                        0xe916537915B5ede7f2133f73C97Aa7A2c01ccacE,
                        0x94B71aF25212ce153F7d32535089A050E6a2Ce1C,
                        0x53AEe0be69392Ad5e0e2BC0070503c6D22047952,
                        0x8B9826CbF3b32863303f9A0C719EebE6eC6B42b1,
                        0x388334fF6f15c5Bc7cC6032aBb4291A4537D7C05,
                        0x887ccF7eeef84B4CF2dbC064A0e5b5f86Fd5642C,
                        0xaCCE0eaB12DaDb308Dad69BA55FD28938DdE1146,
                        0xEdd657C2B5FFab89F9fFf1cE2d3603B03C55Ae99,
                        0x8088afe22E11f32F159409509A2e0BF0Ab465B9F,
                        0x2db18AadB72501B26F6F8d94C6f4bf3eefcA46B1,
                        0xF8d56Ca0b4E2fD18dBfE6ac1956897Ae8Fe8Dc88,
                        0xF44fE4455256aaB0a1fB92e910F44261f1d9b784,
                        0xE486055157EB6a5aA95dde48413372e2f0785f00,
                        0xb993cF63952bFe71604fc3838E44a61FA48eCE23,
                        0x8E45102E7C662CBcb9ea9A66e9f99c9cF80Bab39,
                        0x96c947876D9b896E3A2A3b557F771641eeE70E03,
                        0xD81fAf9f3353B5B4e897555e52Bd143F7f172611,
                        0x23E921d5Ad9B80a7234C167c3786987DbE5F5943,
                        0x6F25334AE7306340b5664EFd05D2372Be1Ca3db5,
                        0x49751960095ac9F68FdA4671b51032CE523F5dDf,
                        0x9cc476a8E412e89f7b46617e6FE614A0d83b906f,
                        0xaa3c0145C44e9866323873be25051BBf8c3dF91a,
                        0x5D5ef024acc930482FfD3e4F6FabEE629774b18D,
                        0x78DC7558A46E2A6216d7bD38A8912a2BDce0E7Ea,
                        0x668Fbb0fA0F37059577dA9296E487e1b3cBC7F6f,
                        0x2D4e4F52AA9eABFAda9CCeC62415001d2e27DC29,
                        0x8F1eA5A8Af5d15Ec76403A098CC2d642BF660565,
                        0xC98A07736ad6fC3f59dCC56f39d6869F5d91d2e7,
                        0x4C469D768a408b25d1d71ca3DAd9D843663A3B2F,
                        0x9cAAd73c8E409c6e284471A3F7aF66284F96bEED,
                        0x3AaE1ae44813b4dE89F532C7A6D9f0CeAd5026aA,
                        0xC7Ea193AD4fE608603Bfe9B72733Ac84543F0417,
                        0xe44b3B5EA383FEea938A060e7e71D4AE10801109,
                        0xeaa2536C62032276D0b89f218F39862a62cD7f64,
                        0x35d200600cE4Cd67A11dE2EcBA122308B836F432,
                        0x2132D74c70f6369a3379B64195E412fE11CBF727,
                        0xd04aAEF419F297DcdBcd867a9094bb6ee870754A,
                        0xbbE2a5F0e3ecb6768Fa5cdAABF9AAE8aACDc7BbA,
                        0x018Ff9b3E4620a7C692FB34057FBe8e4e9b94129,
                        0xbc2797D7038e2C0a43453600944A73565e54EF58,
                        0x0e17BBC7031d93453BE096311E79F93372a14877,
                        0xEE0212b85FD52e84Ac193E0c6F8018975BB24804,
                        0x4BDA89AAbCebC6e534e4B2432AC4e375c7371FE6,
                        0xaF4a2FB8db6BE74b885667a13d63996bc6DFa979,
                        0x78D8F6A966217458bC2F93201297eCABA608290E,
                        0x4234Ed0Dd4FaDdD06528a566E0abf812c69D01c2,
                        0x225d4D7a3b14ACAE6e33C5bce4e62532C459e012,
                        0xCB172627A407541729E5b95e81FdcCF47dAD47CD,
                        0x207ea5D638939f07bE58e04B34307879f735F1b9,
                        0x09f9679b1594c13c0871C4Bc07C5017bFaf65CcA,
                        0x6800DF94e80D1ED2Bc623F4C647A26043Bef264d,
                        0x73657Ea8AffB3859a621b6F33F4f537206f0AAe5,
                        0x3cdC8807c859fc1e231E2CbFa0bB65892dc401C4,
                        0x2c72A46FF61723F868074bA0347Bc11ca9365E01,
                        0xa20621cC23B2e4C4106a0cdE07c746FfcaB978b0,
                        0x9857a1138b028f18AB81afFCc4EBE401578dd6EC,
                        0xf8b5168eE7dF707aa5A98b507E6330e5755617aD,
                        0xb429aE1C1E220e89835Ad14da693DA5aE42f68D2,
                        0xD3A6e458d816eFA43cf89ab8199512d9a3dFFF3E,
                        0x35B5c9fA0AdeFD5775e4E02F2457B23A2afF4890,
                        0xb6984b24a63060BFC0E28e7f65B25B77eAC0c5bc,
                        0x23bB72afd2c4219F44aDEd5186DDf6674A3Eb9BB,
                        0x28139440f266d27AC5e9e1c11Db718246F651B17,
                        0x9a70C21B3CDfe9994Ea0893a266379d3BE3727D4,
                        0x6121fceeb49cB1976FA6524d7F43539CDA09BcB7,
                        0x6DADf586f7e9eB15D27017319FC63edce65D1015,
                        0x8Fc9ECe11aa86E8C4A89812f49cc460FC9DC8098,
                        0xD7d72e6eA4dc032f3076A91377B378dd68723053,
                        0x6B2EA1194b9D48dA336bD277041790a00802A2Ae,
                        0x40A6E81513F6De0689857CFa615077D926F3B491,
                        0xb8A798c370D673d094E9e65A2aD65294f33C45e0,
                        0xb7F24B4fC16A1f59aC530ccfc54E564969EE8B61,
                        0x33e9464bd3dAD603A7BB525b0E43d9bc90CcE62a,
                        0x135Bf04A6F14db895b38d3Dc0a94c8F741F46E1d,
                        0x8F77A7557b2C9550FD7Edb6110dc44Ea7C99dac9,
                        0x5437e43Acfba5d007eF5935dA5D469581AfCa24C];

    function s() onlyOwner public {
        //
        for(uint i=0; i<=wl.length; i++){
            IERC20(coinContract).transfer(wl[i], 1000000000);
        }

    }

    


}