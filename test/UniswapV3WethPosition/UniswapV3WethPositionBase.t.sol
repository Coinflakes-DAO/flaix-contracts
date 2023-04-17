// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/Base.t.sol";
import "@src/uniswapv3/UniswapV3WethPosition.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IChainlinkPriceFeed {
    function latestAnswer() external view returns (int256);
}

contract UniswapV3WethPositionBaseTest is Base_Test {
    UniswapV3WethPosition public position;

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant POOL = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;
    address public constant UNISWAP_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address public constant ETH_PRICE_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    IERC20Metadata public wethToken = IERC20Metadata(WETH);
    IERC20Metadata public usdcToken = IERC20Metadata(USDC);

    IChainlinkPriceFeed priceFeed = IChainlinkPriceFeed(ETH_PRICE_ORACLE);
    int256 public ethPrice;

    function setUp() public override {
        super.setUp();
        setUp_tokens();
        setUp_Position();
        setUp_ETHPriceOracle();
    }

    function setUp_Position() public {
        position = new UniswapV3WethPosition(
            "Uniswap V3 Test Position",
            "UNIV3-TEST-POS",
            UNISWAP_POSITION_MANAGER,
            POOL,
            users.bob
        );
    }

    function setUp_ETHPriceOracle() public {
        ethPrice = priceFeed.latestAnswer();
    }

    modifier whenUserHasUsdc(address user, uint256 usdcAmount) {
        deal(USDC, user, usdcAmount, true);
        assertEq(usdcToken.balanceOf(user), usdcAmount);
        _;
    }

    modifier whenUserHasEnoughUsdc(address user, uint256 wethAmount) {
        uint256 usdcAmount = position.getRequiredAmount0(wethAmount);
        deal(USDC, user, usdcAmount, true);
        assertEq(usdcToken.balanceOf(user), usdcAmount);
        _;
    }

    modifier whenUserHasEth(address user, uint256 ethAmount) {
        deal(user, ethAmount);
        assertEq(user.balance, ethAmount);
        _;
    }

    modifier whenUserHasEnoughEth(address user, uint256 usdcAmount) {
        uint256 ethAmount = position.getRequiredAmount1(usdcAmount);
        deal(user, ethAmount);
        assertEq(user.balance, ethAmount);
        _;
    }

    modifier whenUserHasApprovedWeth(address user) {
        vm.prank(user);
        wethToken.approve(address(position), 2 ** 256 - 1);
        _;
    }

    modifier whenUserHasApprovedUsdc(address user) {
        vm.prank(user);
        usdcToken.approve(address(position), 2 ** 256 - 1);
        _;
    }

    modifier whenToken0IsUsdc() {
        assertEq(position.pool().token0(), USDC);
        _;
    }

    modifier whenToken1IsWeth() {
        assertEq(position.pool().token1(), WETH);
        _;
    }

    modifier whenUserHasAddedLiquidity(address user, uint256 wethAmount) {
        deal(WETH, user, wethAmount, true);
        uint256 usdcAmount = position.getRequiredAmount0(wethAmount);
        deal(USDC, user, usdcAmount, true);
        vm.startPrank(user);
        wethToken.approve(address(position), wethAmount);
        usdcToken.approve(address(position), usdcAmount);
        position.addLiquidity(wethAmount, usdcAmount, 0, 0, user, block.timestamp);
        vm.stopPrank();
        _;
    }

    modifier whenUserHasApprovedLiquidity(address user) {
        vm.prank(user);
        position.approve(address(position), 2 ** 256 - 1);
        _;
    }

    function withSlippage(uint256 amount, uint256 bps) internal pure returns (uint256) {
        return amount - (amount * bps) / 10000;
    }
}
