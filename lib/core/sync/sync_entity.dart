/// Which data syncs, through which channel, and how conflicts resolve.
///
/// The nine things people ask to sync are not one problem. Sorting them
/// by who writes them and how much of them there is gives four groups,
/// and conflating those groups is what makes sync engines unmaintainable.
enum SyncEntity {
  bookmark(channel: SyncChannel.delta, merge: MergeRule.lastWrite),

  /// Highlights are the volume problem: a heavy reader produces thousands
  /// and, unlike bookmarks, they overlap. The entity id is the range key
  /// rather than a client UUID, because two devices highlighting the same
  /// range are making the same statement and must converge to one row
  /// instead of two overlapping ones the reader has to look at.
  highlight(channel: SyncChannel.delta, merge: MergeRule.lastWrite),

  /// Never resolved silently. See MergeRule.surfaceConflict.
  note(channel: SyncChannel.delta, merge: MergeRule.surfaceConflict),

  readingPosition(channel: SyncChannel.delta, merge: MergeRule.furthest),

  hifzCard(channel: SyncChannel.delta, merge: MergeRule.moreRepetitions),

  /// Prayer and notification settings do NOT travel on the sync endpoint.
  /// They are one small object, changed rarely, with no merge semantics
  /// worth writing. PATCH /v1/auth/me/profile already handles them, and
  /// adding them to the delta stream would add two cases to every switch
  /// in this layer while buying nothing.
  prayerSettings(channel: SyncChannel.profilePatch, merge: MergeRule.lastWrite),
  notificationSettings(
      channel: SyncChannel.profilePatch, merge: MergeRule.lastWrite),

  /// Pull only. There is no outbox path and no client write method, which
  /// is enforced structurally: EntitlementRepository has no update().
  entitlement(channel: SyncChannel.pullOnly, merge: MergeRule.serverWins);

  const SyncEntity({required this.channel, required this.merge});

  final SyncChannel channel;
  final MergeRule merge;

  /// Deliberately absent: `favorite`.
  ///
  /// A favourite is Bookmark.isFavorite, not a tenth entity. Giving it a
  /// table of its own means two rows for one user action and an entire
  /// class of conflict that should not be able to exist.
  static const notAnEntity = 'favorite';
}

enum SyncChannel { delta, profilePatch, pullOnly }

enum MergeRule {
  /// Compare client_updated_at, newest wins. Correct where the value is
  /// small and cheaply recreated.
  lastWrite,

  /// The FURTHEST position wins, not the most recent one.
  ///
  /// Someone who reads to page 200 on their phone, then opens a tablet
  /// sitting on page 40 and leaves it idle, must not lose page 200.
  /// Last-write-wins is right for bookmarks and actively destructive
  /// here.
  furthest,

  /// More repetitions wins; timestamp breaks ties. Mirrors
  /// _incoming_wins in apps/sync/services.py exactly.
  moreRepetitions,

  /// The loser is kept as a SyncConflict row and surfaced in the reader.
  ///
  /// Notes are personal reflections written against scripture, and
  /// last-write-wins on a note destroys prose. A bookmark is one bit and
  /// recreating it costs a tap; a paragraph someone wrote at 3am about a
  /// verse that moved them cannot be recreated. apps/sync.SyncConflict
  /// with its losing_payload column exists for this entity.
  surfaceConflict,

  /// The client never writes, so there is nothing to merge.
  serverWins,
}
