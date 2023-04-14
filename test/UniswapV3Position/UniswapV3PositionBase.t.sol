// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/Base.t.sol";
import "@src/uniswapv3/UniswapV3Position.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IChainlinkPriceFeed {
    function latestAnswer() external view returns (int256);
}

contract UniswapV3PositionBaseTest is Base_Test {
    UniswapV3Position public position;

    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant POOL = 0x99ac8cA7087fA4A2A1FB6357269965A2014ABc35;
    address public constant UNISWAP_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address public constant BTC_PRICE_ORACLE = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;

    IERC20Metadata public wbtcToken = IERC20Metadata(WBTC);
    IERC20Metadata public usdcToken = IERC20Metadata(USDC);

    IChainlinkPriceFeed priceFeed = IChainlinkPriceFeed(BTC_PRICE_ORACLE);
    int256 public btcPrice;

    function setUp() public override {
        super.setUp();
        setUp_tokens();
        setUp_Position();
        setUp_BTCPriceOracle();
    }

    function setUp_Position() public {
        position = new UniswapV3Position(
            "Uniswap V3 Test Position",
            "UNIV3-TEST-POS",
            UNISWAP_POSITION_MANAGER,
            POOL,
            users.bob
        );
    }

    function setUp_BTCPriceOracle() public {
        btcPrice = priceFeed.latestAnswer();
    }

    modifier whenUserHasUsdc(address user, uint256 usdcAmount) {
        deal(USDC, user, usdcAmount, true);
        assertEq(usdcToken.balanceOf(user), usdcAmount);
        _;
    }

    modifier whenUserHasEnoughUsdc(address user, uint256 wbtcAmount) {
        uint256 usdcAmount = position.getRequiredAmount1(wbtcAmount);
        deal(USDC, user, usdcAmount, true);
        assertEq(usdcToken.balanceOf(user), usdcAmount);
        _;
    }

    modifier whenUserHasWbtc(address user, uint256 wbtcAmount) {
        deal(WBTC, user, wbtcAmount, true);
        assertEq(wbtcToken.balanceOf(user), wbtcAmount);
        _;
    }

    modifier whenUserHasEnoughWbtc(address user, uint256 usdcAmount) {
        uint256 wbtcAmount = position.getRequiredAmount0(usdcAmount);
        deal(WBTC, user, wbtcAmount, true);
        assertEq(wbtcToken.balanceOf(user), wbtcAmount);
        _;
    }

    modifier whenUserHasApprovedWbtc(address user) {
        vm.prank(user);
        wbtcToken.approve(address(position), 2 ** 256 - 1);
        _;
    }

    modifier whenUserHasApprovedUsdc(address user) {
        vm.prank(user);
        usdcToken.approve(address(position), 2 ** 256 - 1);
        _;
    }

    modifier whenToken0IsWbtc() {
        assertEq(position.pool().token0(), WBTC);
        _;
    }

    modifier whenToken1IsUsdc() {
        assertEq(position.pool().token1(), USDC);
        _;
    }

    modifier whenUserHasAddedLiquidity(address user, uint256 wbtcAmount) {
        deal(WBTC, user, wbtcAmount, true);
        uint256 usdcAmount = position.getRequiredAmount1(wbtcAmount);
        deal(USDC, user, usdcAmount, true);
        vm.startPrank(user);
        wbtcToken.approve(address(position), wbtcAmount);
        usdcToken.approve(address(position), usdcAmount);
        position.addLiquidity(wbtcAmount, usdcAmount, 0, 0, user, block.timestamp);
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
