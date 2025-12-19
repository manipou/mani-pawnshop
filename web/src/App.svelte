<script lang="ts">
	import Computer from "$lib/Computer.svelte";
	import VisibilityProvider from "$lib/providers/VisibilityProvider.svelte";
</script>

<VisibilityProvider>
	<Computer />
</VisibilityProvider>

<style>
	/* Windows XP Scrollbar Styling */
	:global(*::-webkit-scrollbar) {
		width: 16px;
		height: 16px;
	}

	:global(*::-webkit-scrollbar-track) {
		background: #ece9d8;
		border: 1px solid #dfdfdf;
	}

	:global(*::-webkit-scrollbar-thumb) {
		background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%);
		border: 1px solid #dfdfdf;
		box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080;
	}

	:global(*::-webkit-scrollbar-thumb:hover) {
		background: linear-gradient(135deg, #f5f2ea 0%, #cac5bd 100%);
	}

	:global(*::-webkit-scrollbar-thumb:active) {
		background: linear-gradient(135deg, #bfb9b1 0%, #ece9d8 100%);
		box-shadow: inset 1px 1px #808080, inset -1px -1px #ffffff;
	}

	:global(*::-webkit-scrollbar-button) {
		background: linear-gradient(135deg, #ece9d8 0%, #bfb9b1 100%);
		border: 1px solid #dfdfdf;
		box-shadow: inset 1px 1px #ffffff, inset -1px -1px #808080;
		height: 16px;
		width: 16px;
	}

	:global(*::-webkit-scrollbar-button:hover) {
		background: linear-gradient(135deg, #f5f2ea 0%, #cac5bd 100%);
	}

	:global(*::-webkit-scrollbar-button:active) {
		background: linear-gradient(135deg, #bfb9b1 0%, #ece9d8 100%);
		box-shadow: inset 1px 1px #808080, inset -1px -1px #ffffff;
	}

	:global(*::-webkit-scrollbar-button:vertical:decrement) {
		background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath d='M8 6l-4 4h8z' fill='%23000000'/%3E%3C/svg%3E");
		background-repeat: no-repeat;
		background-position: center;
	}

	:global(*::-webkit-scrollbar-button:vertical:increment) {
		background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath d='M8 10l4-4H4z' fill='%23000000'/%3E%3C/svg%3E");
		background-repeat: no-repeat;
		background-position: center;
	}

	:global(*::-webkit-scrollbar-button:horizontal:decrement) {
		background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath d='M6 8l4-4v8z' fill='%23000000'/%3E%3C/svg%3E");
		background-repeat: no-repeat;
		background-position: center;
	}

	:global(*::-webkit-scrollbar-button:horizontal:increment) {
		background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 16 16'%3E%3Cpath d='M10 8l-4 4V4z' fill='%23000000'/%3E%3C/svg%3E");
		background-repeat: no-repeat;
		background-position: center;
	}
</style>