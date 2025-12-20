<script lang="ts">
	import { visibilityStore as visibility, ShopIndex, PawnData, Muted, Config } from "$lib/stores/VisibilityStore";
	import { useNuiEvent } from "$lib/hooks/useNuiEvent";

	useNuiEvent<{ Shop: number, PawnData: any }>("OpenMenu", (Data: { Shop: number, PawnData: any }) => {
		visibility.show();
		ShopIndex.set(Data.Shop);
		PawnData.set(Data.PawnData);

	});

	useNuiEvent<{ Config: any, Muted: boolean }>("InitializeUI", (Data: { Config: any, Muted: boolean }) => {
		Config.set(Data.Config);
		Muted.set(Data.Muted);
	});
</script>

{#if $visibility}
	<slot />
{/if}
